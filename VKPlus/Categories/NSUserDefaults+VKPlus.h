//
//  NSUserDefaults+VKPlus.h
//  VKPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (VKPlus)

@property (strong, nonatomic, readonly, class) NSUserDefaults *vkp_standartDefaults;
+ (void)vkp_resetDefault;

@end

NS_ASSUME_NONNULL_END
