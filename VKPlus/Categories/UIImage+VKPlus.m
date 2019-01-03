//
//  UIImage+VKPlus.m
//  VKPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "UIImage+VKPlus.h"

@implementation UIImage (VKPlus)

+ (UIImage * _Nullable)vkp_iconNamed:(NSString *)name
{
    return [self imageNamed:name inBundle:[NSBundle vkp_defaultBundle] compatibleWithTraitCollection:nil];
}

@end
