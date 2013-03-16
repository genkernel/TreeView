//
//  DASpanCell.h
//  TreeViewExample
//
//  Created by kernel on 14/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAItem.h"

extern NSString *SpanningCellUId;

// Cell that offsets content to the right side basing on spanLevel.
@interface DASpanCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UIView *contentContainer;
@property (strong, nonatomic) IBOutlet UIView *headerContainer;
@property (strong, nonatomic) IBOutlet UIView *dataContainer;
@property (strong, nonatomic) IBOutlet UIView *cellContainer;

- (void)setSpanLevel:(NSUInteger)level;
- (void)loadItem:(DAItem *)item;
- (CGFloat)heightForCellWithItem:(DAItem *)item atLevel:(NSUInteger)level;
@end
