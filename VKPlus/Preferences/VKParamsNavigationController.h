//
//  VKParamsNavigationController.h
//  VKParams
//
//  Created by Даниил on 22/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController ()
@property (assign, nonatomic, readonly) BOOL controllerShouldPop;
@end


@interface VKParamsNavigationController : UINavigationController

@property (assign, nonatomic) IBInspectable BOOL supportsAllOrientations;
@property (assign, nonatomic) IBInspectable BOOL prefersLargeTitle;

@end

NS_ASSUME_NONNULL_END
