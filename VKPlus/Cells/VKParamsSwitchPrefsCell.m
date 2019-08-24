//
//  VKParamsSwitchPrefsCell.m
//  VKParams
//
//  Created by Даниил on 14/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsSwitchPrefsCell.h"
#import "VKParamsImages.h"
#import <objc/runtime.h>

@implementation VKParamsSwitchPrefsCell

+ (Class)switchClass
{
    Class cvkSwitchClass = objc_lookUpClass("ColoredVKSwitch");
    if (cvkSwitchClass)
        return cvkSwitchClass;
    
    return [super switchClass];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.switchView.tintColor = [UIColor clearColor];
        self.switchView.onTintColor = [VKParamsImages mainColor];
        self.switchView.thumbTintColor = [UIColor whiteColor];
        self.switchView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.switchView.layer.cornerRadius = 16.0f;
        self.switchView.layer.masksToBounds = YES;
    }
    return self;
}
@end
