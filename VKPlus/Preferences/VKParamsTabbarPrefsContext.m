//
//  VKParamsTabbarPrefsContext.m
//  VKParams
//
//  Created by Даниил on 16/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTabbarPrefsContext.h"
#import "VKParamsTabbarPrefs.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface VKParamsTabbarPrefsContext () <VKParamsTabbarPrefsDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
@property (assign, nonatomic) BOOL presented;

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) VKParamsTabbarPrefs *tabbarPrefsController;
@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic, readonly) UITabBarController *currentTabbarController;
@property (strong, nonatomic, readonly) UINavigationController *currentNavigationController;
@end

@implementation VKParamsTabbarPrefsContext

- (void)prepareForPresenting
{
    CGFloat navigationBarHeight = CGRectGetMaxY(self.currentNavigationController.navigationBar.frame);
    if (navigationBarHeight < 64.0f)
        navigationBarHeight = 64.0f;
    
    CGFloat tabbarHeight = CGRectGetHeight(self.currentTabbarController.tabBar.frame);
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat edgeOffset = 8.0f;
    CGSize blockSize = CGSizeMake(screenSize.width - edgeOffset * 2.0f, screenSize.height - tabbarHeight - navigationBarHeight - edgeOffset * 2.0f);
    
    self.containerView = [[UIView alloc] initWithFrame:(CGRect){{edgeOffset, navigationBarHeight + edgeOffset}, blockSize}];
    self.containerView.layer.shadowRadius = 14.0f;
    self.containerView.layer.shadowOpacity = 0.3f;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 3.0f);
    self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.tabbarPrefsController = [[VKParamsTabbarPrefs alloc] initForContentSize:blockSize];
    self.tabbarPrefsController.delegate = self;
    
    Class UINavigationControllerClass = objc_lookUpClass("VANavigationController");
    if (!UINavigationControllerClass) {
        UINavigationControllerClass = [UINavigationController class];
    }
    
    self.navigationController = [[UINavigationControllerClass alloc] initWithRootViewController:self.tabbarPrefsController];
    self.navigationController.transitioningDelegate = self;
    self.navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:69/255.0f green:104/255.0f blue:220/255.0f alpha:1.0f];
    
    UIView *navigationView = self.navigationController.view;
    navigationView.frame = self.containerView.bounds;
    [self.containerView addSubview:navigationView];
    
    navigationView.translatesAutoresizingMaskIntoConstraints = NO;
    [navigationView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor].active = YES;
    [navigationView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;
    [navigationView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
    [navigationView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
    
    navigationView.layer.cornerRadius = 14.0f;
    navigationView.layer.masksToBounds = YES;
    
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:navigationView.frame 
                                                                     cornerRadius:navigationView.layer.cornerRadius].CGPath;
}

- (void)presentController
{
    [self prepareForPresenting];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    [self.rootPreferenceController.navigationController popViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [rootViewController presentViewController:self.navigationController animated:YES completion:nil];
    });
}

- (UITabBarController *)currentTabbarController
{
    __kindof UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]])
        return rootViewController;
    
    return nil;
}

- (UINavigationController *)currentNavigationController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:objc_lookUpClass("PairController")])
        rootViewController = [rootViewController sc_executeSelector:@selector(mainController)];
    
    return [rootViewController sc_executeSelector:@selector(currentNavigationController)];
}


#pragma mark -
#pragma mark VKParamsTabbarPrefsDelegate
#pragma mark -

- (void)controllerRequestedDismissing:(VKParamsTabbarPrefs *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.currentNavigationController pushViewController:self.rootPreferenceController animated:YES];
        self.rootPreferenceController = nil;
        self.tabbarPrefsController.delegate = nil;
    }];
}


#pragma mark -
#pragma mark UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning
#pragma mark -

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented 
                                                                            presentingController:(UIViewController *)presenting 
                                                                                sourceController:(UIViewController *)source
{
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (!self.presented) {
        self.presented = YES;
        [self animatePresentTransition:transitionContext];
    } else {
        self.presented = NO;
        [self animatePopTransition:transitionContext];
    }
}

- (void)animatePresentTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGRect originFrame = self.containerView.frame;
    
    CGRect startFrame = originFrame;
    startFrame.origin.x = -CGRectGetWidth(startFrame);
    self.containerView.frame = startFrame;
    
    [transitionContext.containerView addSubview:self.containerView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0.3f options:0 animations:^{
        self.containerView.frame = originFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)animatePopTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    __block CGRect newFrame = self.containerView.frame;
    newFrame.origin.x += 30.0f;
    
    [UIView animateWithDuration:0.15f animations:^{
        self.containerView.frame = newFrame;
    } completion:^(BOOL finishedOne) {
        newFrame.origin.x = - CGRectGetWidth(newFrame) - 30.0f;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.containerView.frame = newFrame;
        } completion:^(BOOL finishedTwo) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }];
}

@end
