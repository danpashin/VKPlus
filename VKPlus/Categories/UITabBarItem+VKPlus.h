//
//  UITabBarItem+VKPlus.h
//  VKPlus
//
//  Created by Даниил on 29/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBarItem (VKPlus)

+ (__kindof UITabBarItem * _Nullable)vkp_itemWithIcon:(UIImage *)icon selectedIcon:(nullable UIImage *)selectedIcon title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
