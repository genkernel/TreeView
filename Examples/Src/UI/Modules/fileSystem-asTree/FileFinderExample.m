//
//  DAViewController.m
//  TreeViewExample
//
//  Created by kernel on 13/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "FileFinderExample.h"
#import "TreeViewExample-Swift.h"

static NSString *Subitems = @"Subitems";
static NSString *Title = @"Title";

@interface FileFinderExample ()
// <indexPath> => @(YES) or nil.
@property (strong, nonatomic, readonly) NSMutableDictionary *expandedItems;

@property (strong, nonatomic, readonly) NSFileManager *fm;
@property (strong, nonatomic, readonly) NSString *rootPath;
@property (strong, nonatomic, readonly) NSArray *rootItems;
@end

@implementation FileFinderExample
@synthesize name = _name;

- (instancetype)init {
	self = [super init];
	if (self) {
		_name = @"FileFinder (file system as a tree)";
		
		_expandedItems = @{}.mutableCopy;
		_fm = NSFileManager.defaultManager;
		
		_rootPath = NSBundle.mainBundle.bundlePath;
		_rootItems = [self.fm contentsOfDirectoryAtPath:self.rootPath error:nil];
	}
	return self;
}

- (void)registerCustomCellsWith:(UITableView *)tableView {
	Class cls = UITableViewCell.class;
	NSString *identifier =  NSStringFromClass(cls);
	
	[tableView registerClass:cls forCellReuseIdentifier:identifier];
}

- (NSString *)filePathForIndexPath:(NSIndexPath *)ip {
	NSString *path = self.rootPath.copy;
	
	for (int i = 1; i < ip.length; i++) {
		NSUInteger idx = [ip indexAtPosition:i];
		
		NSArray *items = [self.fm contentsOfDirectoryAtPath:path error:nil];
		
		path = [path stringByAppendingPathComponent:items[idx]];
	}
	
	return path;
}

#pragma mark TreeTableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.rootItems.count;
}

- (BOOL)tableView:(UITableView *)tableView isCellExpanded:(NSIndexPath *)indexPath {
	return [self.expandedItems[indexPath] boolValue];
}

- (NSUInteger)tableView:(UITableView *)tableView numberOfSubCellsForCellAtIndexPath:(NSIndexPath *)indexPath {
	NSString *filePath = [self filePathForIndexPath:indexPath];
	
	NSArray *paths = [self.fm contentsOfDirectoryAtPath:filePath error:nil];
	
	return paths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *filePath = [self filePathForIndexPath:indexPath];
	
	NSString *identifier =  NSStringFromClass(UITableViewCell.class);
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	cell.indentationLevel = indexPath.length - 1;
	
	
	BOOL isDirectory = NO;
	[self.fm fileExistsAtPath:filePath isDirectory:&isDirectory];
	
	cell.accessoryType = isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	
	cell.textLabel.text = filePath.lastPathComponent;
	
//	NSLog(@"%@ -> %@", indexPath, filePath);
	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)tableIndexPath {
	[tableView deselectRowAtIndexPath:tableIndexPath animated:YES];
	
	NSIndexPath *treeIndexPath = [tableView treeIndexPathFromTablePath:tableIndexPath];
	
	BOOL isExpanded = [tableView isExpanded:treeIndexPath];
	if (isExpanded) {
		[self.expandedItems removeObjectForKey:treeIndexPath];
		
		[tableView collapse:treeIndexPath];
		
	} else {
		NSString *filePath = [self filePathForIndexPath:treeIndexPath];
		
		BOOL isDirectory = NO;
		[self.fm fileExistsAtPath:filePath isDirectory:&isDirectory];
		
		if (!isDirectory) {
			return;
		}
		
		self.expandedItems[treeIndexPath] = @(YES);
		[tableView expand:treeIndexPath];
	}
}

@end
