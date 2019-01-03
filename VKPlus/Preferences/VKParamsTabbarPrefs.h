//
//  VKParamsTabbarPrefs.h
//  VKParams
//
//  Created by Даниил on 16/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsPreferences.h"

NS_ASSUME_NONNULL_BEGIN

@class VKParamsTabbarPrefs;
@protocol VKParamsTabbarPrefsDelegate <NSObject>

- (void)controllerRequestedDismissing:(VKParamsTabbarPrefs *)controller;

@end

@interface VKParamsTabbarPrefs : VKParamsPreferences
@property (strong, nonatomic, nullable)  id <VKParamsTabbarPrefsDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
