//
// TreeView.m
//
// Author: kernel@realm
//

#import "TreeTable.h"

@interface TreeTable()
@property (strong, nonatomic, readonly) NSMutableDictionary *model, *directModel;
@property (nonatomic) NSUInteger rootItemsCount;
@end

@implementation TreeTable

- (id)init {
	self = [super init];
	if (self) {
		_model = NSMutableDictionary.dictionary;
		_directModel = NSMutableDictionary.dictionary;
		
		self.expandingAnimation = UITableViewRowAnimationAutomatic;
		self.closingAnimation = UITableViewRowAnimationAutomatic;
	}
	return self;
}

#pragma mark Instance methods

- (NSIndexPath *)tableIndexPathFromTreePath:(NSIndexPath *)indexPath {
	NSUInteger row = [self rowOffsetForIndexPath:indexPath];
	return [NSIndexPath indexPathForRow:row inSection:0];
}

/**
 * Converts TreeTable indexPath to TableView row index.
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
	NSNumber *num = self.directModel[root];
	if (num) {
		subitemsCount = num.intValue;
	} else {
		if ([self.dataSource tableView:self.tableView isCellExpanded:root]) {
			subitemsCount = [self.dataSource tableView:self.tableView numberOfSubCellsForCellAtIndexPath:root];
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

- (BOOL)isExpanded:(NSIndexPath *)indexPath {
	return nil != self.directModel[indexPath];
}

- (void)expand:(NSIndexPath *)indexPath {
	if ([self isExpanded:indexPath]) {
		return;
	}
	
	[self numberOfSubitems:indexPath];
	
	NSMutableArray *insertRows = [NSMutableArray array];
	[self expand:indexPath array:insertRows];
	
	[self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)expand:(NSIndexPath *)indexPath array:(NSMutableArray *)rows {
	NSUInteger section = indexPath.section;
	NSUInteger count = [self.directModel[indexPath] unsignedIntegerValue];
		
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

- (NSArray*)siblings:(NSIndexPath *)indexPath {
	NSIndexPath * parent = [self parent:indexPath];
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
	
	// TODO: dont use "numberOfSections" as it triggers dataSource methods.
	for (int i = 0; i < self.tableView.numberOfSections; i++) {
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

- (void)close:(NSIndexPath *)indexPath {
	if (![self isExpanded:indexPath]) {
		return;
	}
	
	NSMutableArray * dismissRows = [NSMutableArray array];
	[self close:indexPath array:dismissRows];
	
	[self.tableView deleteRowsAtIndexPaths:dismissRows withRowAnimation:self.closingAnimation];
}

- (void)close:(NSIndexPath *)indexPath array:(NSMutableArray *)rows {
	NSUInteger section = indexPath.section;
	NSUInteger count = [self.directModel[indexPath] unsignedIntegerValue];
	
	if (count > 0) {
		NSUInteger row = 0;
		NSMutableArray *dismissRows = [NSMutableArray arrayWithCapacity:count];
		for (NSUInteger i = 0; i < count; i++) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			
			row = [self rowOffsetForIndexPath:ip];
			[dismissRows addObject:[NSIndexPath indexPathForRow:row inSection:section]];
		}
		[rows addObjectsFromArray:dismissRows];
		
		for (int i = count-1; i >= 0; i--) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			[self close:ip array:rows];
		}
	}
	
	[self.model removeObjectForKey:indexPath];
	[self.directModel removeObjectForKey:indexPath];
}

- (NSUInteger)numberOfSubitems:(NSIndexPath *)indexPath {
	NSUInteger count = 0;
	
	BOOL isExpanded = NO;
	if (1 == indexPath.length) {
		// Sections are always expanded.
		isExpanded = YES;
	} else {
		isExpanded = [self.dataSource tableView:self.tableView isCellExpanded:indexPath];
	}
	
	if (isExpanded) {
		NSUInteger subitemsCount = [self.dataSource tableView:self.tableView numberOfSubCellsForCellAtIndexPath:indexPath];
		
		for (int i=0; i<subitemsCount; i++ ) {
			NSIndexPath *subitemPath = [indexPath indexPathByAddingIndex:i];
			count += [self numberOfSubitems:subitemPath];
		}
		
		count += subitemsCount;
		[self.directModel setObject:@(subitemsCount) forKey:indexPath];
	}
	
	[self.model setObject:@(count) forKey:indexPath];
	return count;
}

- (NSIndexPath *)treeIndexPathForItem:(UITableViewCell *)item {
	NSIndexPath *tableIndexPath = [self.tableView indexPathForCell:item];
	return [self treeIndexPathFromTablePath:tableIndexPath];
}

- (NSIndexPath *)treeIndexOfRow:(NSUInteger)row root:(NSIndexPath *)root offset:(NSUInteger)offset {
	//
	// TODO: - Check boundaries.
	
	NSUInteger count = 0;
	
	NSIndexPath *ip = nil;
	NSUInteger num = [[self.model objectForKey:root] unsignedIntValue];
	
	if (0 == num) {
		return root;
	}
	
	for (int i = 0; i < num; i++) {
		if (row == count) {
			return [root indexPathByAddingIndex:i];
		}
		
		ip = [root indexPathByAddingIndex:i];
		NSUInteger numValue = [[self.model objectForKey:ip] unsignedIntegerValue];
		
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
	NSUInteger rowsCount = [self.directModel[ip] unsignedIntegerValue];
	
	for (NSUInteger r = 0; r < rowsCount; r++) {
		if (row == count) {
			return [NSIndexPath indexPathForRow:r inSection:section];
		}
		
		NSIndexPath *ip = [NSIndexPath indexPathForRow:r inSection:section];
		NSUInteger numValue = [[self.model objectForKey:ip] unsignedIntegerValue];
		
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

- (UITableViewCell *)itemForTreeIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *ip = [self tableIndexPathFromTreePath:indexPath];
	return [self.tableView cellForRowAtIndexPath:ip];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_tableView = tableView;
	
	NSUInteger rows = [self.dataSource tableView:tableView numberOfRowsInSection:section];
	NSUInteger totalRowsCount = rows;
	
	NSIndexPath *ip = [NSIndexPath indexPathWithIndex:section];
	self.directModel[ip] = @(rows);
	
	for (int i = 0; i < rows; i++) {
		NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:section];
		totalRowsCount += [self numberOfSubitems:ip];
	}
	
	self.model[ip] = @(totalRowsCount);
	
	return totalRowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath * itemPath = [self treeIndexPathFromTablePath:indexPath];
	
	if (!itemPath) {
		NSLog(@"ERR. nil indexPath specified. %s", __PRETTY_FUNCTION__);
		return nil;
	}
	return [self.dataSource tableView:self.tableView cellForRowAtIndexPath:itemPath];
}

@end
