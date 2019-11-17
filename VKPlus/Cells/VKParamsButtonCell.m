//
//  VKParamsButtonCell.m
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsButtonCell.h"
#import "VKParamsImages.h"

@implementation VKParamsButtonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.titleLabel.textColor = VKParamsImages.mainColor;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
        [self userTapped];
}

- (void)userTapped
{
    SEL actionSelector = NSSelectorFromString([self.specifier propertyForKey:@"action"]);
    if (actionSelector && [self.specifier.target respondsToSelector:actionSelector]) {
        NSMethodSignature *actionSignature = [self.specifier.target methodSignatureForSelector:actionSelector];
        if (actionSignature.numberOfArguments == 2) {
            [self.specifier.target sc_executeSelector:actionSelector];
        } else if (actionSignature.numberOfArguments == 3) {
            [self.specifier.target sc_executeSelector:actionSelector arguments:self, nil];
        }
    }
}

@end
