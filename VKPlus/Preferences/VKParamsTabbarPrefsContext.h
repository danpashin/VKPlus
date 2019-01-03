//
//  VKParamsTabbarPrefsContext.h
//  VKParams
//
//  Created by Даниил on 16/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsTabbarPrefsContext : NSObject

@property (strong, nonatomic, nullable) UIViewController *rootPreferenceController;

- (void)presentController;

@end

NS_ASSUME_NONNULL_END
