//
//  UITabBarItem+VKPlus.m
//  VKPlus
//
//  Created by Даниил on 29/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "UITabBarItem+VKPlus.h"
#import <objc/runtime.h>

#import "VKViews.h"
#import "VKModels.h"

@implementation UITabBarItem (VKPlus)

+ (__kindof UITabBarItem *)vkp_itemWithIcon:(UIImage *)icon selectedIcon:(UIImage *)selectedIcon title:(NSString *)title
{
    Class tabbarItemClass = objc_lookUpClass("VATabbarItem");
    
    __kindof UITabBarItem *item = nil;
    if (tabbarItemClass) {
        UIColor *selectedTintColor = [objc_lookUpClass("VAColor") tabbarActiveIcon];
        UIColor *unselectedTintColor = [objc_lookUpClass("VAColor") tabbarInactiveIcon];
        VATabbarItemImageView *itemImageView = [[objc_lookUpClass("VATabbarItemImageView") alloc] initWithImage:icon 
                                                                                              selectedTintColor:selectedTintColor
                                                                                            unselectedTintColor:unselectedTintColor];
        item = [(VATabbarItem *)[tabbarItemClass alloc] initWithView:itemImageView];
        
    } else {
        tabbarItemClass = objc_lookUpClass("VKTabbarItem") ?:  [UITabBarItem class];
        item = [[tabbarItemClass alloc] initWithTitle:title image:icon selectedImage:selectedIcon];
    }
    
    if ([item respondsToSelector:@selector(setSuppressTitleChange:)])
        ((VKTabBarItem *)item).suppressTitleChange = YES;
    
    item.imageInsets = UIEdgeInsetsMake(6.0f, 0, -6.0f, 0);
    item.titlePositionAdjustment = UIOffsetMake(0.0, 50.0);
    item.accessibilityLabel = title;
    item.isAccessibilityElement = YES;
    
    return item;
}

@end
