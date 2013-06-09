//
//  TreeView.m
//
// Author: kernel@realm
//

#import "TreeTable.h"

@interface TreeTable()
@property (strong, nonatomic, readonly) NSMutableDictionary * model, *directModel;
@property (nonatomic) NSUInteger rootItemsCount;

- (NSUInteger)numberOfSubitems:(NSIndexPath *)indexPath;

- (void)close:(NSIndexPath *)indexPath array:(NSMutableArray *)diissRows;
- (void)expand:(NSIndexPath *)indexPath array:(NSMutableArray *)rows;

- (NSIndexPath *)treeIndexOfRow:(NSUInteger)row;
- (NSIndexPath *)treeIndexOfRow:(NSUInteger)row root:(NSIndexPath *)root offset:(NSUInteger)offset;

- (NSUInteger)rowOffsetForIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)rowOffsetForIndexPath:(NSIndexPath *)indexPath root:(NSIndexPath *)root;
@end

@implementation TreeTable

- (id)init {
	self = [super init];
	if (self) {
		_model = [NSMutableDictionary dictionary];
		_directModel = [NSMutableDictionary dictionary];
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
	NSUInteger totalCount = 0;
	
	for (int i=0; i<self.rootItemsCount; i++) {
		NSIndexPath *ip = [NSIndexPath indexPathWithIndex:i];
		if (i==[indexPath indexAtPosition:0]) {
			NSUInteger count = [self rowOffsetForIndexPath:indexPath root:ip];
			totalCount += count;
			break;
		} else {
			NSNumber* num = [self.model objectForKey:ip];
			totalCount += [num intValue]+1;
		}
	}
	return totalCount;
}

- (NSUInteger)rowOffsetForIndexPath:(NSIndexPath *)indexPath root:(NSIndexPath *)root {
	if (NSOrderedSame == [indexPath compare:root]) {
		return 0;
	}
	
	NSUInteger totalCount = 1;
	
	NSUInteger subitemsCount = 0;
	NSNumber* num = [self.directModel objectForKey:root];
	if (num) {
		subitemsCount = num.intValue;
	} else {
		if ([self.dataSource tableView:self.tableView isCellExpanded:root]) {
			subitemsCount = [self.dataSource tableView:self.tableView numberOfSubCellsForCellAtIndexPath:root];
		}
	}
	
	for (int i=0; i<subitemsCount; i++) {
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
	
	NSMutableArray * insertRows = [NSMutableArray array];
	[self expand:indexPath array:insertRows];
	
	[self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)expand:(NSIndexPath *)indexPath array:(NSMutableArray *)rows {
	NSNumber* num = [self.directModel objectForKey:indexPath];
	NSUInteger count = [num intValue];
		
	if (count > 0) {
		for (int i=0; i<count; i++) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			[self expand:ip array:rows];
		}
		
		NSMutableArray * insertRows = [NSMutableArray arrayWithCapacity:count];
		for (int i=0; i<count; i++) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			NSUInteger row = [self rowOffsetForIndexPath:ip];
			[insertRows addObject:[NSIndexPath indexPathForRow:row inSection:0]];
			//NSLog(@"Insert(T): %@", [NSIndexPath indexPathForRow:row inSection:0]);
		}
		[rows addObjectsFromArray:insertRows];
	}
	
	//NSLog(@"Expanded. Model: %@", self.model);
	//NSLog(@"Expanded. DirectModel: %@", self.directModel);
}

- (NSArray*)siblings:(NSIndexPath *)indexPath {
	NSIndexPath * parent = [self parent:indexPath];
	
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
	for (int i=0; i<self.rootItemsCount; i++) {
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
	
	[self.tableView deleteRowsAtIndexPaths:dismissRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)close:(NSIndexPath *)indexPath array:(NSMutableArray *)rows {
	NSNumber* num = [self.directModel objectForKey:indexPath];
	
	NSUInteger count = [num intValue];
	if (count>0) {
		
		NSUInteger row = 0;
		NSMutableArray * dismissRows = [NSMutableArray arrayWithCapacity:count];
		for (int i=0; i<count; i++) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			
			row = [self rowOffsetForIndexPath:ip];
			[dismissRows addObject:[NSIndexPath indexPathForRow:row inSection:0]];
		}
		[rows addObjectsFromArray:dismissRows];
		
		for (int i=count-1; i>=0; i--) {
			NSIndexPath *ip = [indexPath indexPathByAddingIndex:i];
			[self close:ip array:rows];
		}
	}
	
	[self.model removeObjectForKey:indexPath];
	[self.directModel removeObjectForKey:indexPath];
	
	//NSLog(@"Closed. Model: %@", self.model);
	//NSLog(@"Closed. DirectModel: %@", self.directModel);
}

- (NSUInteger)numberOfSubitems:(NSIndexPath *)indexPath {
	NSUInteger count = 0;
	
	if ([self.dataSource tableView:self.tableView isCellExpanded:indexPath]) {
		NSUInteger subitemsCount = [self.dataSource tableView:self.tableView numberOfSubCellsForCellAtIndexPath:indexPath];
		for (int i=0; i<subitemsCount; i++ ) {
			NSIndexPath * subitemPath = [indexPath indexPathByAddingIndex:i];
			count += [self numberOfSubitems:subitemPath];
		}
		count += subitemsCount;
		[self.directModel setObject:@(subitemsCount) forKey:indexPath];
	}
	[self.model setObject:@(count) forKey:indexPath];
	
	return count;
}

- (NSIndexPath *)indexPathForItem:(UITableViewCell*)item {
	NSIndexPath * tableIndexPath = [self.tableView indexPathForCell:item];
	return [self treeIndexOfRow:tableIndexPath.row];
}

- (NSIndexPath *)treeIndexOfRow:(NSUInteger)row root:(NSIndexPath *)root offset:(NSUInteger)offset {
	//
	// TODO: - Check boundaries.
	
	NSUInteger count = 0;
	
	NSIndexPath *ip = nil;
	NSNumber* num = [self.model objectForKey:root];
	if (0==num.intValue) {
		return root;
	}
	for (int i=0; i<[num intValue]; i++) {
		if (row == count) {
			return [root indexPathByAddingIndex:i];
		}
		
		ip = [root indexPathByAddingIndex:i];
		NSNumber* num = [self.model objectForKey:ip];
		
		count += 1;
		NSUInteger numValue = [num intValue];
		if (row < numValue+count) {
			return [self treeIndexOfRow:row-count root:ip offset:count];
		}
		
		count += numValue;
	}
	return ip;
}

- (NSIndexPath *)treeIndexOfRow:(NSUInteger)row {
	NSUInteger count = 0;
	
	for (int i=0; i<self.rootItemsCount; i++) {
		if (row == count) {
			return [NSIndexPath indexPathWithIndex:i];
		}
		
		NSIndexPath *ip = [NSIndexPath indexPathWithIndex:i];
		NSNumber* num = [self.model objectForKey:ip];
		
		count += 1;
		NSUInteger numValue = [num intValue];
		if (row < numValue+count) {
			return [self treeIndexOfRow:row-count root:ip offset:count];
		}
		
		count += numValue;
	}
	return nil;
}

- (UITableViewCell*)itemForIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [self rowOffsetForIndexPath:indexPath];
	return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}


#pragma mark UITableViewDelegate, -DataSource

#pragma mark Sections & Footers

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// TODO: Impl Sections & Footers support.
	return 1;
}

#pragma mark Cells

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_tableView = tableView;
	
	// IndexPath==nil:  root items.
	NSUInteger totalCount = self.rootItemsCount = [self.dataSource tableView:self.tableView numberOfSubCellsForCellAtIndexPath:nil];
	
	// Calc subitems of expanded items.
	for (int i=0; i<self.rootItemsCount; i++ ) {
		totalCount += [self numberOfSubitems:[NSIndexPath indexPathWithIndex:i]];
	}
	
	return totalCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath * itemPath = [self treeIndexOfRow:indexPath.row];
	if (!itemPath) {
		NSLog(@"ERR. Invalid itemPath: %@", itemPath);
		return nil;
	}
	return [self.dataSource tableView:self.tableView cellForRowAtIndexPath:itemPath];
}

@end
