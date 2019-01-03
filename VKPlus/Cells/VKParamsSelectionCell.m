//
//  VKParamsSelectionCell.m
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsSelectionCell.h"

@interface VKParamsSelectionCell ()
@end

@implementation VKParamsSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.indentationLevel = 5;
        
        _tickView = [[VKParamsTickView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
        [self.contentView addSubview:self.tickView];
        
        self.tickView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tickView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
        [self.tickView.widthAnchor constraintEqualToConstant:CGRectGetWidth(self.tickView.frame)].active = YES;
        [self.tickView.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.tickView.frame)].active = YES;
        [self.tickView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12.0f].active = YES;
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    self.tickView.enabled = [self.specifier.performGetter boolValue];
}

@end
