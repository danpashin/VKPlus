//
//  VKParamsProxyEditController.h
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsPreferences.h"
#import "VKParamsProxyModel.h"

NS_ASSUME_NONNULL_BEGIN

@class VKParamsProxyEditController;
@protocol VKParamsProxyEditControllerDelegate <NSObject>

- (void)proxyEditController:(VKParamsProxyEditController *)proxyEditController didEndEditingModel:(VKParamsProxyModel *)proxyModel;

@end

@interface VKParamsProxyEditController : VKParamsPreferences

@property (weak, nonatomic) id <VKParamsProxyEditControllerDelegate> delegate;

- (instancetype)initWithProxyModel:(VKParamsProxyModel *)proxyModel;
- (void)presentFrom:(UIViewController *)controller;


+ (id)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
