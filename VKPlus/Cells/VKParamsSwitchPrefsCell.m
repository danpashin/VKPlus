//
//  VKParamsSwitchPrefsCell.m
//  VKParams
//
//  Created by Даниил on 14/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsSwitchPrefsCell.h"
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
        self.switchView.thumbTintColor = [UIColor whiteColor];
        self.switchView.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:239/255.0f alpha:1.0f];
        self.switchView.layer.cornerRadius = 16.0f;
        self.switchView.layer.masksToBounds = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = self.switchView.bounds;
            gradientLayer.colors = @[(id)[UIColor colorWithRed:69/255.0f green:104/255.0f blue:220/255.0f alpha:1.0f].CGColor, 
                                     (id)[UIColor colorWithRed:176/255.0f green:106/255.0f blue:179/255.0f alpha:1.0f].CGColor];
            gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
            gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
            
            UIGraphicsBeginImageContextWithOptions(self.switchView.frame.size, NO, [UIScreen mainScreen].scale);
            [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.switchView.onTintColor = [UIColor colorWithPatternImage:gradientImage];
        });
    }
    return self;
}
@end
