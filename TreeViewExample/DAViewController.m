//
//  DAViewController.m
//  TreeViewExample
//
//  Created by kernel on 13/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAViewController.h"

@interface DAViewController ()
@property (strong, nonatomic, readonly) DAPlanetStore *store;
// <indexPath> => @(YES) or nil.
@property (strong, nonatomic, readonly) NSMutableDictionary *expandedItems;
// This cell is reused to calculate cell height based on dynamic text content.
@property (strong, nonatomic, readonly) DASpanCell *firstCell;
@end

@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSString *name =  NSStringFromClass(DASpanCell.class);
	UINib *nib = [UINib nibWithNibName:name bundle:nil];
	[self.treeView.tableView registerNib:nib forCellReuseIdentifier:SpanningCellUId];
	
	_firstCell = [self.treeView.tableView dequeueReusableCellWithIdentifier:SpanningCellUId];
	
	_expandedItems = [NSMutableDictionary dictionary];
	_store = [DAPlanetStore defaultStore];
}

#pragma mark TreeTableViewDataSource, -Delegate

- (BOOL)treeView:(TreeTableView *)treeView expanded:(NSIndexPath *)indexPath {
	return nil != self.expandedItems[indexPath];
}

- (NSUInteger)treeView:(TreeTableView *)treeView numberOfSubitems:(NSIndexPath *)indexPath {
	if (indexPath) {
		DAItem *item = [self.store itemForIndexPath:indexPath];
		return [self.store numberOfSubitemsForItem:item];
	} else {
		// nil indexPath - return items number for root (no parent).
		return self.store.rootItems.count;
	}
}

- (UITableViewCell *)treeView:(TreeTableView *)treeView itemForIndexPath:(NSIndexPath *)indexPath {
	DAItem *item = [self.store itemForIndexPath:indexPath];
	
	DASpanCell *cell = [treeView.tableView dequeueReusableCellWithIdentifier:SpanningCellUId];
	[cell setSpanLevel:indexPath.length];
	
	[cell loadItem:item];
	
	return cell;
}

- (void)treeView:(TreeTableView *)treeView clicked:(NSIndexPath *)indexPath {
	NSIndexPath *tableIndexPath = [treeView tableIndexPathFromTreePath:indexPath];
	[treeView.tableView deselectRowAtIndexPath:tableIndexPath animated:YES];
	
	BOOL isExpanded = [treeView isExpanded:indexPath];
	if (isExpanded) {
		[self.expandedItems removeObjectForKey:indexPath];
		
		[treeView close:indexPath];
	} else {
		self.expandedItems[indexPath] = @(YES);
		
		[treeView expand:indexPath];
	}
}

- (CGFloat)treeView:(TreeTableView *)treeView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
	DAItem *item = [self.store itemForIndexPath:indexPath];
	return [self.firstCell heightForCellWithItem:item atLevel:indexPath.length];
}

@end
