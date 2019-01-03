//
//  NSUserDefaults+VKPlus.m
//  VKPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "NSUserDefaults+VKPlus.h"

@implementation NSUserDefaults (VKPlus)

+ (NSUserDefaults *)vkp_standartDefaults
{
    return [[self alloc] initWithSuiteName:productBundleIdentifier];
}

+ (void)vkp_resetDefault
{
    NSUserDefaults *userDefaults = self.vkp_standartDefaults;
    [userDefaults removePersistentDomainForName:productBundleIdentifier];
}

@end
