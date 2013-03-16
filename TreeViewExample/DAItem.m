//
//  DAItem.m
//  TreeViewExample
//
//  Created by kernel on 15/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DAItem.h"

@interface DAItem ()
@property (readwrite) DAItemType type;
@property (strong, nonatomic, readwrite) id dataSource;
@property (strong, nonatomic, readwrite) NSString *name;
@end

@implementation DAItem

+ (NSMutableDictionary *)store {
	static NSMutableDictionary *store = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		store = [NSMutableDictionary dictionary];
	});
	return store;
}

+ (DAItem *)dictItemWithName:(NSString *)name dict:(NSDictionary *)dict ip:(NSIndexPath *)ip {
	DAItem *item = self.store[ip];
	if (!item) {
		item = [self createItemWithName:name source:dict];
		item.type = DADictionaryItem;
		
		self.store[ip] = item;
	}
	return item;
}

+ (DAItem *)arrayItemWithName:(NSString *)name items:(NSArray *)items ip:(NSIndexPath *)ip {
	DAItem *item = self.store[ip];
	if (!item) {
		item = [self createItemWithName:name source:items];
		item.type = DAArrayItem;
		
		self.store[ip] = item;
	}
	return item;
}

+ (DAItem *)infoItemWithName:(NSString *)name value:(NSString *)source ip:(NSIndexPath *)ip {
	DAItem *item = self.store[ip];
	if (!item) {
		item = [self createItemWithName:name source:source];
		item.type = DAFinalItem;
		
		self.store[ip] = item;
	}
	return item;
}

+ (DAItem *)createItemWithName:(NSString *)name source:(id)source {
	DAItem *item = [DAItem new];
	
	item.name = name;
	item.dataSource = source;
	
	return item;
}

@end
