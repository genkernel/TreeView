//
//  DAViewController.m
//  TreeViewExample
//
//  Created by kernel on 13/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAViewController.h"

static NSString *Subitems = @"Subitems";
static NSString *Title = @"Title";

@interface DAViewController ()
// <indexPath> => @(YES) or nil.
@property (strong, nonatomic, readonly) NSMutableDictionary *expandedItems;
@property (strong, nonatomic, readonly) NSArray *easy;
@end

@implementation DAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_expandedItems = NSMutableDictionary.dictionary;
	
	NSString *path = [NSBundle.mainBundle pathForResource:@"Easy" ofType:@"plist"];
	_easy = [NSArray arrayWithContentsOfFile:path];
	
	Class cls = UITableViewCell.class;
	NSString *identifier =  NSStringFromClass(cls);
	[self.treeView registerClass:cls forCellReuseIdentifier:identifier];
}

- (NSDictionary *)itemForIndexPath:(NSIndexPath *)indexPath {
	NSArray *items = self.easy;
	NSDictionary *item = self.easy[[indexPath indexAtPosition:0]];
	
	for (int i = 0; i < indexPath.length; i++) {
		NSUInteger idx = [indexPath indexAtPosition:i];
		
		item = items[idx];
		
		if (i == indexPath.length - 1) {
			return item;
		}
		
		items = item[Subitems];
	}
	
	return item;
}

#pragma mark TreeTableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.easy.count;
}

- (BOOL)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *item = self.easy[section];
	return [item[Subitems] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDictionary *item = self.easy[section];
	return item[Title];
}

- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath {
	return nil != self.expandedItems[indexPath];
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *item = [self itemForIndexPath:indexPath];
	return [item[Subitems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *item = [self itemForIndexPath:indexPath];
	
	NSString *identifier =  NSStringFromClass(UITableViewCell.class);
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	cell.indentationLevel = indexPath.length - 1;
	
	NSString *title = nil;
	if ([item isKindOfClass:NSDictionary.class]) {
		title = item[Title];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		title = (NSString *)item;
		
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = title;
	
//	NSLog(@"%@ -> %@", indexPath, title);
	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)tableIndexPath {
	[tableView deselectRowAtIndexPath:tableIndexPath animated:YES];
	
	NSIndexPath *treeIndexPath = [self.treeModel treeIndexPathFromTablePath:tableIndexPath];
	
	BOOL isExpanded = [self.treeModel isExpanded:treeIndexPath];
	if (isExpanded) {
		[self.expandedItems removeObjectForKey:treeIndexPath];
		[self.treeModel close:treeIndexPath];
	} else {
		NSDictionary *item = [self itemForIndexPath:treeIndexPath];
		if ([item isKindOfClass:NSString.class]) {
			return;
		}
		
		self.expandedItems[treeIndexPath] = @(YES);
		[self.treeModel expand:treeIndexPath];
	}
}

@end
