//
//  DAItem.h
//  TreeViewExample
//
//  Created by kernel on 15/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DAUnknownItem,
	DADictionaryItem,
	DAArrayItem,
	DAFinalItem
} DAItemType;

@interface DAItem : NSObject
+ (DAItem *)dictItemWithName:(NSString *)name dict:(NSDictionary *)dict ip:(NSIndexPath *)ip;
+ (DAItem *)arrayItemWithName:(NSString *)name items:(NSArray *)items ip:(NSIndexPath *)ip;
+ (DAItem *)infoItemWithName:(NSString *)name value:(NSString *)source ip:(NSIndexPath *)ip;

@property (readonly) DAItemType type;
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) id dataSource;
@end
