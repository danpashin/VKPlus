//
//  NSBundle+VKPlus.m
//  VKPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "NSBundle+VKPlus.h"

@implementation NSBundle (VKPlus)

+ (NSBundle *)vkp_defaultBundle
{
    static NSBundle *vkp_defaultBundle = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#ifdef COMPILE_DEB
        vkp_defaultBundle = [NSBundle bundleWithPath:@"/Library/Application Support/VKPlusPlus.bundle"];
#else
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VKPlusPlus" ofType:@"bundle"];
        vkp_defaultBundle = [NSBundle bundleWithPath:path];
#endif
    });
    
    return vkp_defaultBundle;
}

@end
