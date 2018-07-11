//
// TreeView.m
//
// Author: kernel@realm
//

#import "TreeTable.h"

@interface UITableView (Internal)
- (NSUInteger)numberOfSubitems:(NSIndexPath *)indexPath;
@end

@interface TreeTable()
@property (strong, nonatomic, readonly) NSMutableDictionary *model, *directModel;
@property (nonatomic) NSUInteger rootItemsCount;
@end

@implementation TreeTable

- (id)init {
	self = [super init];
	if (self) {
		_model = @{}.mutableCopy;
		_directModel = @{}.mutableCopy;
		
		self.closingAnimation = UITableViewRowAnimationAutomatic;
		self.expandingAnimation = UITableViewRowAnimationAutomatic;
	}
	return self;
}

#pragma mark Forwarding to Original DataSource

- (id)forwardingTargetForSelector:(SEL)selector {
	if ([self.dataSource respondsToSelector:selector]) {
		return self.dataSource;
	}
	return nil;
}

- (BOOL)respondsToSelector:(SEL)selector {
	BOOL responds = [super respondsToSelector:selector];
	if (responds) {
		return responds;
	}
	return [self.dataSource respondsToSelector:selector];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
		return [self.dataSource numberOfSectionsInTableView:tableView];
	}
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_tableView = tableView;
	
	NSUInteger rows = [self.dataSource tableView:tableView numberOfRowsInSection:section];
	NSUInteger totalRowsCount = rows;
	
	NSIndexPath *ip = [NSIndexPath indexPathWithIndex:section];
	self.directModel[ip] = @(rows);
	
	for (int i = 0; i < rows; i++) {
		NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:section];
		totalRowsCount += [self.tableView numberOfSubitems:ip];
	}
	
	self.model[ip] = @(totalRowsCount);
	
	return totalRowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath * itemPath = [self.tableView treeIndexPathFromTablePath:indexPath];
	
	if (!itemPath) {
		NSLog(@"ERR. nil indexPath specified. %s", __PRETTY_FUNCTION__);
		return nil;
	}
	return [self.dataSource tableView:self.tableView cellForRowAtIndexPath:itemPath];
}

@end


@implementation UITableView (TreeTable)
@dynamic treeProxy;

- (TreeTable *)treeProxy {
	return (TreeTable *)self.dataSource;
}

- (NSIndexPath *)tableIndexPathFromTreePath:(NSIndexPath *)indexPath {
	NSUInteger row = [self rowOffsetForIndexPath:indexPath];
	return [NSIndexPath indexPathForRow:row inSection:indexPath.section];
}

/**
 Converts TreeTable indexPath to TableView row index.
 */
- (NSUInteger)rowOffsetForIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath indexAtPosition:0];
	NSIndexPath *ip = [NSIndexPath indexPathWithIndex:section];
	
	return [self rowOffsetForIndexPath:indexPath root:ip];
}

- (NSUInteger)rowOffsetForIndexPath:(NSIndexPath *)indexPath root:(NSIndexPath *)root {
	if (NSOrderedSame == [indexPath compare:root]) {
		return 0;
	}
	
	NSUInteger totalCount = 0;
	if (root.length > 1) {
		totalCount++;
	}
	
	NSUInteger subitemsCount = 0;
	NSNumber *num = self.treeProxy.directModel[root];
	if (num) {
		subitemsCount = num.intValue;
	} else {
		if ([self.treeProxy.dataSource tableView:self isCellExpanded:root]) {
			subitemsCount = [self.treeProxy.dataSource tableView:self numberOfSubCellsForCellAtIndexPath:root];
		}
	}
	
	for (int i = 0; i < subitemsCount; i++) {
		NSIndexPath *ip = [root indexPathByAddingIndex:i];
		
		if (NSOrderedAscending != [ip compare:indexPath]) {
			break;
		}
		
		if (ip.length < indexPath.length) {
			// cell@indexPath is inner comparing to cell@ip.
			NSUInteger count = [self rowOffsetForIndexPath:indexPath root:ip];
			totalCount += count;
		} else {
			NSUInteger count = [self rowOffsetForIndexPath:indexPath root:ip];
			totalCount += count;
		}
	}
	
	return totalCount;
}

- (NSUInteger)numberOfSubitems:(NSIndexPath *)indexPath {
	NSUInteger count = 0;
	
	BOOL isExpanded = NO;
	if (1 == indexPath.length) {
		// Sections are always expanded.
		isExpanded = YES;
	} else {
		isExpanded = [self.treeProxy.dataSource tableView:self isCellExpanded:indexPath];
	}
	
	if (isExpanded) {
		NSUInteger subitemsCount = [self.treeProxy.dataSource tableView:self numberOfSubCellsForCellAtIndexPath:indexPath];
		
		for (int i=0; i<subitemsCount; i++ ) {
			NSIndexPath *subitemPath = [indexPath indexPathByAddingIndex:i];
			count += [self numberOfSubitems:subitemPath];
		}
		
		count += subitemsCount;
		[self.treeProxy.directModel setObject:@(subitemsCount) forKey:indexPath];
	}
	
	[self.treeProxy.model setObject:@(count) forKey:indexPath];
	return count;
}

- (NSIndexPath *)treeIndexPathForCell:(UITableViewCell *)item {
	NSIndexPath *tableIndexPath = [self indexPathForCell:item];
	return [self treeIndexPathFromTablePath:tableIndexPath];
}

- (NSIndexPath *)treeIndexOfRow:(NSUInteger)row root:(NSIndexPath *)root offset:(NSUInteger)offset {
	//
	// TODO: - Check boundaries.
	
	NSUInteger count = 0;
	
	NSIndexPath *ip = nil;
	NSUInteger num = [self.treeProxy.model[root] unsignedIntValue];
	
	if (0 == num) {
		return root;
	}
	
	for (int i = 0; i < num; i++) {
		if (row == count) {
			return [root indexPathByAddingIndex:i];
		}
		
		ip = [root indexPathByAddingIndex:i];
		NSUInteger numValue = [self.treeProxy.model[ip] unsignedIntegerValue];
		
		count += 1;
		if (row < numValue + count) {
			return [self treeIndexOfRow:row-count root:ip offset:count];
		}
		
		count += numValue;
	}
	return ip;
}

- (NSIndexPath *)treeIndexPathFromTablePath:(NSIndexPath *)indexPath {
	NSUInteger count = 0;
	
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	
	NSIndexPath *ip = [NSIndexPath indexPathWithIndex:section];
	NSUInteger rowsCount = [self.treeProxy.directModel[ip] unsignedIntegerValue];
	
	for (NSUInteger r = 0; r < rowsCount; r++) {
		if (row == count) {
			return [NSIndexPath indexPathForRow:r inSection:section];
		}
		
		NSIndexPath *ip = [NSIndexPath indexPathForRow:r inSection:section];
		NSUInteger numValue = [self.treeProxy.model[ip] unsignedIntegerValue];
		
		count += 1;
		
		if (row < numValue + count) {
			NSIndexPath *ip = [NSIndexPath indexPathForRow:r inSection:section];
			return [self treeIndexOfRow:row-count root:ip offset:count];
		}
		
		count += numValue;
	}
	
	NSLog(@"ERR. Error while converting tableIndexPath into treeIndexPath. %s", __PRETTY_FUNCTION__);
	return nil;
}

- (UITableViewCell *)rowForTreeIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *ip = [self tableIndexPathFromTreePath:indexPath];
	return [self cellForRowAtIndexPath:ip];
}

- (BOOL)isExpanded:(NSIndexPath *)indexPath {
	return nil != self.treeProxy.directModel[indexPath];
}

- (void)expand:(NSIndexPath *)indexPath {
	if ([self isExpanded:indexPath]) {
		return;
	}
	
	[self numberOfSubitems:indexPath];
	
	NSMutableArray *insertRows = [NSMutableArray array];
	[self expand:indexPath array:insertRows];
	
	[self insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)expand:(NSIndexPath *)indexPath array:(NSMutableArray *)rows {
	NSUInteger section = indexPath.section;
	NSUInteger count = [self.treeProxy.directModel[indexPath] unsignedIntegerValue];
	
	if (count > 0) {
		for (int i = 0; i < count; i++) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			[self expand:ip array:rows];
		}
		
		NSMutableArray *insertRows = [NSMutableArray arrayWithCapacity:count];
		for (NSUInteger i = 0; i < count; i++) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			NSUInteger row = [self rowOffsetForIndexPath:ip];
			
			[insertRows addObject:[NSIndexPath indexPathForRow:row inSection:section]];
		}
		[rows addObjectsFromArray:insertRows];
	}
}

- (NSArray *)siblings:(NSIndexPath *)indexPath {
	NSIndexPath * parent = [self parent:indexPath];
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
	
	// TODO: dont use "numberOfSections" as it triggers dataSource methods.
	for (int i = 0; i < self.numberOfSections; i++) {
		NSIndexPath *ip = nil;
		if (parent) {
			ip = [parent indexPathByAddingIndex:i];
		} else {
			ip = [NSIndexPath indexPathWithIndex:i];
		}
		if (NSOrderedSame == [ip compare:indexPath]) {
			continue;
		}
		[arr addObject:ip];
	}
	return arr;
}

- (NSIndexPath *)parent:(NSIndexPath *)indexPath {
	if ([indexPath length]>1) {
		return [indexPath indexPathByRemovingLastIndex];
	} else {
		return nil;
	}
}

- (void)collapse:(NSIndexPath *)indexPath {
	if (![self isExpanded:indexPath]) {
		return;
	}
	
	NSMutableArray * dismissRows = [NSMutableArray array];
	[self collapse:indexPath array:dismissRows];
	
	[self deleteRowsAtIndexPaths:dismissRows withRowAnimation:self.treeProxy.closingAnimation];
}

- (void)collapse:(NSIndexPath *)indexPath array:(NSMutableArray *)rows {
	NSUInteger section = indexPath.section;
	int count = [self.treeProxy.directModel[indexPath] intValue];
	
	if (count > 0) {
		NSUInteger row = 0;
		NSMutableArray *dismissRows = [NSMutableArray arrayWithCapacity:count];
		for (int i = 0; i < count; i++) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			
			row = [self rowOffsetForIndexPath:ip];
			[dismissRows addObject:[NSIndexPath indexPathForRow:row inSection:section]];
		}
		[rows addObjectsFromArray:dismissRows];
		
		for (int i = count-1; i >= 0; i--) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			[self collapse:ip array:rows];
		}
	}
	
	[self.treeProxy.model removeObjectForKey:indexPath];
	[self.treeProxy.directModel removeObjectForKey:indexPath];
}

@end
