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

- (CGFloat)widthOffsetForSpanLevel:(NSUInteger)level {
	return level * kSpanLevelWidth;
}

- (void)setSpanLevel:(NSUInteger)level {
	CGFloat width = [self widthOffsetForSpanLevel:level];
	
	CGRect r = CGRectMake(width, .0, self.frame.size.width - width, self.frame.size.height);
	self.contentContainer.frame = r;
	
	CGFloat colorLevel = 1. - level * .075;
	UIColor *color = [UIColor colorWithWhite:colorLevel alpha:1.];
	self.cellContainer.backgroundColor = color;
}

- (NSString *)nameOfItem:(DAItem *)item {
	return DAFinalItem == item.type ? item.name : @"";
}

- (NSString *)descOfItem:(DAItem *)item {
	return DAFinalItem == item.type ? item.dataSource : item.name;
}

- (void)loadItem:(DAItem *)item {
	self.tagLabel.text = [self nameOfItem:item];
	self.valueLabel.text = [self descOfItem:item];
}

- (CGFloat)heightForCellWithItem:(DAItem *)item atLevel:(NSUInteger)level {
	CGFloat offset = [self widthOffsetForSpanLevel:level];
	CGFloat width = self.frame.size.width - offset;
	
	NSString *desc = [self descOfItem:item];
	
	CGSize s = CGSizeMake(width, 1024.);
	s = [desc sizeWithFont:self.valueLabel.font constrainedToSize:s];
	
	return self.headerContainer.frame.size.height + s.height;
}

@end
