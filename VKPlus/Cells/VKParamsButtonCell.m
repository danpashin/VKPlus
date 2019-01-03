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
        dispatch_async(dispatch_get_main_queue(), ^{
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = self.titleLabel.bounds;
            gradientLayer.colors = @[(id)VKParamsImages.mainColor.CGColor, 
                                     (id)VKParamsImages.secondaryColor.CGColor];
            gradientLayer.startPoint = CGPointMake(0.5f, 1.0f);
            gradientLayer.endPoint = CGPointMake(0.5f, 0);
            
            UIGraphicsBeginImageContextWithOptions(self.titleLabel.frame.size, NO, [UIScreen mainScreen].scale);
            [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.titleLabel.textColor = [UIColor colorWithPatternImage:gradientImage];
        });
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
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
