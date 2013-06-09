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

#pragma mark TreeTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath {
	return nil != self.expandedItems[indexPath];
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath) {
		DAItem *item = [self.store itemForIndexPath:indexPath];
		return [self.store numberOfSubitemsForItem:item];
	} else {
		// nil indexPath - return items number for root (no parent).
		return self.store.rootItems.count;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DAItem *item = [self.store itemForIndexPath:indexPath];
	
	DASpanCell *cell = [tableView dequeueReusableCellWithIdentifier:SpanningCellUId];
	[cell setSpanLevel:indexPath.length];
	
	[cell loadItem:item];
	
	return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)tableIndexPath {
	NSIndexPath *treeIndexPath = [self.treeModel treeIndexOfRow:tableIndexPath.row];
	
	DAItem *item = [self.store itemForIndexPath:treeIndexPath];
	return [self.firstCell heightForCellWithItem:item atLevel:treeIndexPath.length];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)tableIndexPath {
	[tableView deselectRowAtIndexPath:tableIndexPath animated:YES];
	
	NSIndexPath *treeIndexPath = [self.treeModel treeIndexOfRow:tableIndexPath.row];
	
	BOOL isExpanded = [self.treeModel isExpanded:treeIndexPath];
	if (isExpanded) {
		[self.expandedItems removeObjectForKey:treeIndexPath];
		
		[self.treeModel close:treeIndexPath];
	} else {
		self.expandedItems[treeIndexPath] = @(YES);
		
		[self.treeModel expand:treeIndexPath];
	}
}

@end
