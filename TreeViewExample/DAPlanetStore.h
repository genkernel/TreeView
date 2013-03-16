//
//  DAPlanetStore.h
//  TreeViewExample
//
//  Created by kernel on 15/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAItem.h"

@interface DAPlanetStore : NSObject
+ (DAPlanetStore *)defaultStore;

@property (strong, nonatomic, readonly) NSArray *rootItems;

- (void)loadWithSourceFileAtPath:(NSString *)path;

- (DAItem *)itemForIndexPath:(NSIndexPath *)ip;
- (NSUInteger)numberOfSubitemsForItem:(DAItem *)item;
@end
