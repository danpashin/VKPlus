//
//  VKViews.h
//  VKParams
//
//  Created by Даниил on 15/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//


@interface VKTabBarItem : UITabBarItem
@property (strong, nonatomic) UIView *customBadgeView;
@property (assign, nonatomic) BOOL suppressTitleChange;
- (void)showDot:(BOOL)shouldShowDot;
@end


@interface VATabbarItem : UITabBarItem
- (instancetype)initWithView:(UIView *)view;
@end


@interface VATabbarItemView : UIView
@end

@interface VATabbarItemImageView : VATabbarItemView
- (instancetype)initWithImage:(UIImage *)image selectedTintColor:(UIColor *)selectedTint 
          unselectedTintColor:(UIColor *)unselectedTint;
@end
