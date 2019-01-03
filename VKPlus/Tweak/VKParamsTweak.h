//
//  VKParamsTweak.h
//  VKParams
//
//  Created by Даниил on 15/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import <CaptainHook/CaptainHook.h>
#import "VKParamsUserPrefs.h"
#import "VKParamsFunctions.h"

#import "VKModels.h"
#import "VKControllers.h"
#import "VKViews.h"
#import "VKParamsTabbarModel.h"

@class VKParamsMainPreferences;
extern NSUInteger preferencesTabbarIndex;
extern __weak VKParamsMainPreferences *vkp_weakPreferences;

extern NSNumber *currentUserID;

extern NSString *applicationBuildNumber;
extern NSString *certificateTID;
