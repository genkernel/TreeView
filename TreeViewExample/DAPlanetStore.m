//
//  DAPlanetStore.m
//  TreeViewExample
//
//  Created by kernel on 15/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAPlanetStore.h"

// Every entity is required to have at least 1 'Name' field.
static NSString *NameKey = @"Name";

@implementation DAPlanetStore

+ (DAPlanetStore *)defaultStore {
	static DAPlanetStore *store = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		store = [self.class new];
		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Planets" ofType:@"plist"];
		[store loadWithSourceFileAtPath:path];
	});
	return store;
}

- (void)loadWithSourceFileAtPath:(NSString *)path {
	_rootItems = [NSArray arrayWithContentsOfFile:path];
}

- (DAItem *)itemForIndexPath:(NSIndexPath *)indexPath {
	// Root object definitely exists.
	NSUInteger idx = [indexPath indexAtPosition:0];
	id source = self.rootItems[idx];
	
	// Root object is always NSDictionary.
	NSDictionary *dict = source;
	NSString *name = dict[NameKey];
	
	DAItem *item = [DAItem dictItemWithName:name dict:source ip:[NSIndexPath indexPathWithIndex:idx]];
	
	// Find requested inner object.
	for (int i = 1; i < indexPath.length; i++) {
		idx = [indexPath indexAtPosition:i];
		
		if ([source isKindOfClass:NSDictionary.class]) {
			NSDictionary *dict = source;
			name = dict.allKeys[idx];
			source = dict[name];
		} else if ([source isKindOfClass:NSArray.class]) {
			NSArray *arr = source;
			source = arr[idx];
			
			if ([source isKindOfClass:NSDictionary.class]) {
				NSDictionary *dict = source;
				name = dict[NameKey];
			} else {
				name = nil;
			}
		} else {
			return nil;
		}
	}
	
	if ([source isKindOfClass:NSDictionary.class]) {
		item = [DAItem dictItemWithName:name dict:source ip:indexPath];
	} else if ([source isKindOfClass:NSArray.class]) {
		item = [DAItem arrayItemWithName:name items:source ip:indexPath];
	} else {
		item = [DAItem infoItemWithName:name value:source ip:indexPath];
	}
	return item;
}

- (NSUInteger)numberOfSubitemsForItem:(DAItem *)item {
	switch (item.type) {
		case DADictionaryItem: {
			NSDictionary *dict = item.dataSource;
			return dict.count;
		}
		case DAArrayItem: {
			NSArray *arr = item.dataSource;
			return arr.count;
		}
		default:
			return 0;
	}
}

@end
