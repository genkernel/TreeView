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
	[self.treeView registerNib:nib forCellReuseIdentifier:SpanningCellUId];
	
	_firstCell = [self.treeView dequeueReusableCellWithIdentifier:SpanningCellUId];
	
	_expandedItems = [NSMutableDictionary dictionary];
	_store = [DAPlanetStore defaultStore];
}

#pragma mark TreeTableDataSource, -Delegate

- (BOOL)treeView:(UITableView *)treeView expanded:(NSIndexPath *)indexPath {
	return nil != self.expandedItems[indexPath];
}

- (NSUInteger)treeView:(UITableView *)treeView numberOfSubitems:(NSIndexPath *)indexPath {
	if (indexPath) {
		DAItem *item = [self.store itemForIndexPath:indexPath];
		return [self.store numberOfSubitemsForItem:item];
	} else {
		// nil indexPath - return items number for root (no parent).
		return self.store.rootItems.count;
	}
}

- (UITableViewCell *)treeView:(UITableView *)treeView itemForIndexPath:(NSIndexPath *)indexPath {
	DAItem *item = [self.store itemForIndexPath:indexPath];
	
	DASpanCell *cell = [treeView dequeueReusableCellWithIdentifier:SpanningCellUId];
	[cell setSpanLevel:indexPath.length];
	
	[cell loadItem:item];
	
	return cell;
}

- (void)treeView:(UITableView *)treeView clicked:(NSIndexPath *)indexPath {
	NSIndexPath *ip = [self.treeModel tableIndexPathFromTreePath:indexPath];
	[treeView deselectRowAtIndexPath:ip animated:YES];
	
	BOOL isExpanded = [self.treeModel isExpanded:indexPath];
	if (isExpanded) {
		[self.expandedItems removeObjectForKey:indexPath];
		
		[self.treeModel close:indexPath];
	} else {
		self.expandedItems[indexPath] = @(YES);
		
		[self.treeModel expand:indexPath];
	}
}

- (CGFloat)treeView:(UITableView *)treeView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
	DAItem *item = [self.store itemForIndexPath:indexPath];
	return [self.firstCell heightForCellWithItem:item atLevel:indexPath.length];
}

- (void)viewDidUnload {
    [self setTreeModel:nil];
    [super viewDidUnload];
}
@end
