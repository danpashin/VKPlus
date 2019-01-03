//
//  VKParamsImages.m
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsImages.h"

@interface VKParamsImages ()

@end

@implementation VKParamsImages

+ (UIColor *)mainColor
{
    return [UIColor colorWithRed:69/255.0f green:104/255.0f blue:220/255.0f alpha:1.0f];
}

+ (UIColor *)secondaryColor
{
    return [UIColor colorWithRed:176/255.0f green:106/255.0f blue:179/255.0f alpha:1.0f];
}

+ (UIColor *)iconColor
{
    return [UIColor colorWithRed:135/255.0f green:150/255.0f blue:163/255.0f alpha:1.0f];
}

+ (void)executeBlock:(void(^)(void))block
{
    if (!block)
        return;
    
    [NSThread isMainThread] ? block() : dispatch_sync(dispatch_get_main_queue(), block);
}

+ (UIImage *)addIcon
{
    return [self addIconWithSize:CGSizeMake(20.0f, 20.0f)];
}

+ (UIImage *)addIconWithSize:(CGSize)size
{
    __block UIImage *addIcon = nil;
    [self executeBlock:^{
        CGRect addIconRect = (CGRect){{0.0f, 0.0f}, size};
        UIGraphicsBeginImageContextWithOptions(addIconRect.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, 2.25f);
        CGContextSetLineCap(context, kCGLineCapRound);
        
        CGMutablePathRef mutablePath = CGPathCreateMutable();
        
//        Горизонталь
        CGPathMoveToPoint(mutablePath, NULL, CGRectGetMinX(addIconRect) + 1.0f, CGRectGetMidY(addIconRect));
        CGPathAddLineToPoint(mutablePath, NULL, CGRectGetMaxX(addIconRect) - 1.0f, CGRectGetMidY(addIconRect));
//        Вертикаль
        CGPathMoveToPoint(mutablePath, NULL, CGRectGetMidX(addIconRect), CGRectGetMinY(addIconRect) + 1.0f);
        CGPathAddLineToPoint(mutablePath, NULL, CGRectGetMidX(addIconRect), CGRectGetMaxY(addIconRect) - 1.0f);
        
        CGContextAddPath(context, mutablePath);
        CGPathRelease(mutablePath);
        
        CGContextReplacePathWithStrokedPath(context);
        CGContextClip(context);
        
        NSArray *gradientColors = @[(id)self.secondaryColor.CGColor,
                                    (id)self.mainColor.CGColor ];
        
        const CGFloat colorLocations[] = { 0.0f, 1.0f };
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, colorLocations);
        CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0.0f, CGRectGetMaxY(addIconRect)), 0.0f);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        addIcon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }];
    
    return addIcon;
}

@end
