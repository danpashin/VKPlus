//
//  VKParamsTabbar.m
//  VKParams
//
//  Created by Даниил on 15/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTweak.h"

CHDeclareClass(VKMMainController);
CHDeclareMethod(0, void, VKMMainController, setupTabBarControllers)
{
//    CHSuper(0, VKMMainController, setupTabBarControllers);
    vkp_vkMainController = self;
    if ([self respondsToSelector:@selector(setNavigationControllerDelegate:)])
        self.navigationControllerDelegate = [objc_lookUpClass("DiscoverNavigationDelegate") delegateWithNavigationStats:self.main.session.navigationStats];
    else if ([self respondsToSelector:@selector(setNavigationDelegate:)]) {
        Class delegateClass = objc_lookUpClass("MainNavigationDelegate");
        if ([delegateClass respondsToSelector:@selector(delegateWithNavigationStats:)]) {
            self.navigationDelegate = [delegateClass delegateWithNavigationStats:self.main.session.navigationStats];
        } else {
            self.navigationDelegate = [delegateClass new];
        }
    }
    
    [VKParamsTabbarModel rebuildTabbarItems];
    vkp_vkMainController.selectedIndex = selectedTabbarIndex;
}

