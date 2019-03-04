//
//  VKParamsTabbarModel+VKModule.m
//  VKPlus
//
//  Created by Даниил on 21/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTabbarModel.h"

#import "VKModels.h"
#import "VKControllers.h"
#import "VKViews.h"
#import <objc/runtime.h>
#import "VKParamsFunctions.h"
#import "UITabBarItem+VKPlus.h"

#import "ColoredVKSwiftMenuButton.h"
#import "ColoredVKSwiftMenuController.h"

#import "VKParamsMainPreferences.h"
#import <SCAlertController.h>

extern VKMMainController *vkp_vkMainController;
NSUInteger preferencesTabbarIndex;
__weak VKParamsMainPreferences *vkp_weakPreferences;

extern BOOL shouldUpdateTabbar;
extern NSDictionary <NSNumber *, VKParamsTabbarModel *> *tabbarModels;
extern __strong NSNumber *currentUserID;
extern long long cachedUnreadMessagesCount;

@implementation VKParamsTabbarModel (VKModule)

+ (BOOL)setupQuickMenuController
{
    if (![vkp_vkMainController isKindOfClass:[UITabBarController class]])
        return NO;
    
    Class ColoredVKSwiftMenuControllerClass = objc_lookUpClass("ColoredVKSwiftMenuController");
    Class ColoredVKSwiftMenuItemsGroupClass = objc_lookUpClass("ColoredVKSwiftMenuItemsGroup");
    Class ColoredVKSwiftMenuButtonClass     = objc_lookUpClass("ColoredVKSwiftMenuButton");
    
    if (!ColoredVKSwiftMenuControllerClass || !ColoredVKSwiftMenuItemsGroupClass || !ColoredVKSwiftMenuButtonClass)
        return NO;
    
    ColoredVKSwiftMenuController *swiftMenuController = [ColoredVKSwiftMenuControllerClass menuControllerForController:vkp_vkMainController];
    if (!swiftMenuController)
        return NO;
    
    __weak typeof(swiftMenuController) weakSwiftMenuController = swiftMenuController;
    
    ColoredVKSwiftMenuButton *presentPrefsItem = [[ColoredVKSwiftMenuButtonClass alloc] init];
    presentPrefsItem.icon = [UIImage vkp_iconNamed:@"settings_normal_30_white"];
    presentPrefsItem.canHighlight = NO;
    presentPrefsItem.selectHandler = ^(ColoredVKSwiftMenuButton * _Nonnull menuButton) {
        [self presentSettings];
    };
    
    ColoredVKSwiftMenuButton *resetSettingsItem = [[ColoredVKSwiftMenuButtonClass alloc] init];
    resetSettingsItem.icon = [UIImage imageNamed:@"replay_36"];
    resetSettingsItem.canHighlight = NO;
    resetSettingsItem.selectHandler = ^(ColoredVKSwiftMenuButton * _Nonnull menuButton) {
        [self resetSettingsWithCompletion:^{
            [weakSwiftMenuController dismissViewControllerAnimated:YES completion:nil];
        }];
    };
    
    
    ColoredVKSwiftMenuItemsGroup *group = [[ColoredVKSwiftMenuItemsGroupClass alloc] initWithButtons:@[resetSettingsItem, presentPrefsItem]];
    group.name = @"VK++";
    [swiftMenuController.itemsGroups addObject:group];
    
    return YES;
}

+ (void)rebuildTabbarItems
{
    if (!vkp_vkMainController)
        return;
    
    NSMutableArray <__kindof UIViewController *> *tabbarControllers = [NSMutableArray array];
    
    for (NSNumber *modelIndex in [tabbarModels.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        VKParamsTabbarModel *model = tabbarModels[modelIndex];
        SEL viewControllerSelector = NSSelectorFromString(model.modelSelector);
        if (!viewControllerSelector)
            continue;
        
        UIViewController *viewController  = nil;
        if ([model.modelSelector isEqualToString:@"menu"]) {
            MenuModel *menuModel = [[objc_lookUpClass("MenuModel") alloc] initWithSession:vkp_vkMainController.main.session];
            viewController = [[objc_lookUpClass("MenuViewController") alloc] initWithMain:vkp_vkMainController.main andModel:menuModel];
            vkp_vkMainController.menuController = viewController;
        } else if ([model.modelSelector isEqualToString:@"docs:"]) {
            viewController = [vkp_vkMainController.main sc_executeSelector:viewControllerSelector arguments:currentUserID, nil];
        } else if ([model.modelSelector isEqualToString:@"photos:userOnly:"]) {
            if (currentUserID == nil) {
                currentUserID = [[NSUserDefaults vkp_standartDefaults] objectForKey:@"cachedUserID"];
            }
            
            viewController = [vkp_vkMainController.main sc_executeSelector:viewControllerSelector arguments:currentUserID, @YES, nil];
        } else {
            viewController = [vkp_vkMainController.main sc_executeSelector:viewControllerSelector];
        }
        
        if (!viewController)
            continue;
        
        UINavigationController *navigationController = [[objc_lookUpClass("VKMNavigationController") alloc] initWithRootViewController:viewController];
        
        if ([vkp_vkMainController respondsToSelector:@selector(navigationControllerDelegate)])
            navigationController.delegate = vkp_vkMainController.navigationControllerDelegate;
        else if ([vkp_vkMainController respondsToSelector:@selector(navigationDelegate)])
            navigationController.delegate = vkp_vkMainController.navigationDelegate;
        
        [tabbarControllers addObject:navigationController];
        
        NSBundle *iconBundle = model.iconFromVKApp ? [NSBundle mainBundle] : [NSBundle vkp_defaultBundle];
        UIImage *icon = [UIImage imageNamed:model.imageName inBundle:iconBundle compatibleWithTraitCollection:nil];
        UIImage *selectedIcon = [UIImage imageNamed:model.selectedImageName inBundle:iconBundle compatibleWithTraitCollection:nil];
        
        navigationController.tabBarItem = [UITabBarItem vkp_itemWithIcon:icon selectedIcon:selectedIcon title:model.title];
        
        
        if ([model.modelSelector isEqualToString:@"messagesDialogs"]) {
            vkp_vkMainController.dialogsController = viewController;
            navigationController.tabBarItem.badgeValue = navigationController.tabBarItem.badgeValue;
        }
    }
    
    [vkp_vkMainController setViewControllers:tabbarControllers animated:NO];
}

+ (void)resetSettingsWithCompletion:(void(^)(void))completion
{
    SCAlertController *alert = [SCAlertController alertControllerWithTitle:VKPLocalized(@"reset_preferences_alert_title") 
                                                                   message:VKPLocalized(@"reset_preferences_alert_subtitle")];
    [alert addCancelAction];
    [alert addAction:[UIAlertAction actionWithTitle:VKPLocalized(@"reset_preferences_confirmation") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (completion)
            completion();
        
        [NSUserDefaults vkp_resetDefault];
        
        shouldUpdateTabbar = YES;
        reloadPrefs();
    }]];
    [alert present];
}

+ (void)presentSettings
{
    Class ColoredVKSwiftMenuControllerClass = objc_lookUpClass("ColoredVKSwiftMenuController");
    ColoredVKSwiftMenuController *swiftMenuController = [ColoredVKSwiftMenuControllerClass menuControllerForController:vkp_vkMainController];
    if (!swiftMenuController)
        return;
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [swiftMenuController dismissViewControllerAnimated:YES completion:^{
            if (vkp_weakPreferences) {
                if (preferencesTabbarIndex > vkp_vkMainController.viewControllers.count - 1)
                    preferencesTabbarIndex = 0;
                
                if (preferencesTabbarIndex == vkp_vkMainController.selectedIndex)
                    return;
                
                UIView *fromView = vkp_vkMainController.selectedViewController.view;
                UIView *toView = vkp_vkMainController.viewControllers[preferencesTabbarIndex].view;
                [fromView.superview addSubview:toView];
                
                BOOL scrollToRight = preferencesTabbarIndex > vkp_vkMainController.selectedIndex;
                
                CGRect endFromViewFrame = fromView.frame;
                endFromViewFrame.origin.x = scrollToRight ? -CGRectGetWidth(endFromViewFrame) : CGRectGetWidth(endFromViewFrame);
                
                CGRect endToViewFrame = toView.frame;
                CGRect startToViewFrame = toView.frame;
                startToViewFrame.origin.x = scrollToRight ? CGRectGetWidth(startToViewFrame) : -CGRectGetWidth(startToViewFrame);
                toView.frame = startToViewFrame;
                
                [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:0.3f options:0 animations:^{
                    fromView.frame = endFromViewFrame;
                    toView.frame = endToViewFrame;
                } completion:^(BOOL finished) {
                    [fromView removeFromSuperview];
                    vkp_vkMainController.selectedIndex = preferencesTabbarIndex;      
                }];
                
                return;
            }
            
            if ([vkp_vkMainController respondsToSelector:@selector(currentNavigationController)]) {
                UINavigationController *navController = vkp_vkMainController.currentNavigationController;
                
                VKParamsMainPreferences *prefs = [VKParamsMainPreferences new];
                [navController pushViewController:prefs animated:YES];
                
                vkp_weakPreferences = prefs;
                preferencesTabbarIndex = vkp_vkMainController.selectedIndex;
            }
        }];
    });
}

@end
