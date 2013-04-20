//
//  DASpanCell.m
//  TreeViewExample
//
//  Created by kernel on 14/03/13.
//  Copyright (c) 2013 kernel@realm. All rights reserved.
//

#import "DASpanCell.h"

static CGFloat kSpanLevelWidth = 20.;
NSString *SpanningCellUId = @"SpanningCellUID";

@implementation DASpanCell

- (void)setSpanLevel:(NSUInteger)level {
	CGFloat width = [self.class widthOffsetForSpanLevel:level];
	
	CGRect r = CGRectMake(width, .0, self.frame.size.width - width, self.frame.size.height);
	self.contentContainer.frame = r;
	
	CGFloat colorLevel = 1. - level * .075;
	UIColor *color = [UIColor colorWithWhite:colorLevel alpha:1.];
	self.cellContainer.backgroundColor = color;
}

- (void)loadItem:(DAItem *)item {
	self.tagLabel.text = [self.class nameOfItem:item];
	self.valueLabel.text = [self.class descOfItem:item];
}

+ (NSString *)nameOfItem:(DAItem *)item {
	return DAFinalItem == item.type ? item.name : @"";
}

+ (NSString *)descOfItem:(DAItem *)item {
	return DAFinalItem == item.type ? item.dataSource : item.name;
}

+ (CGFloat)widthOffsetForSpanLevel:(NSUInteger)level {
	return level * kSpanLevelWidth;
}

- (CGFloat)heightForCellWithItem:(DAItem *)item atLevel:(NSUInteger)level {
	CGFloat offset = [self.class widthOffsetForSpanLevel:level];
	CGFloat width = self.frame.size.width - offset;
	
	NSString *desc = [self.class descOfItem:item];
	
	CGSize s = CGSizeMake(width, 1024.);
	s = [desc sizeWithFont:self.valueLabel.font constrainedToSize:s];
	
	return self.headerContainer.frame.size.height + s.height;
}

@end
