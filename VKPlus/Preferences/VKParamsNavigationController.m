//
//  VKParamsNavigationController.m
//  VKParams
//
//  Created by Даниил on 22/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsNavigationController.h"
#import "VKParamsImages.h"

@interface VKParamsNavigationController ()

@end

@implementation VKParamsNavigationController


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.supportsAllOrientations)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIColor *barTintColor = self.navigationBar.barTintColor;
    if (barTintColor) {
        const CGFloat *components = CGColorGetComponents(barTintColor.CGColor);
        CGFloat white = (components[0] + components[1] + components[2]) / 3.0f;
        
        return (white < 0.7f) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
    
    return UIStatusBarStyleDefault;
}


- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup
{
    _supportsAllOrientations = NO;
    _prefersLargeTitle = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = VKParamsImages.mainColor;
    self.prefersLargeTitle = self.prefersLargeTitle;
}

- (void)setPrefersLargeTitle:(BOOL)prefersLargeTitle
{
    _prefersLargeTitle = prefersLargeTitle;
    
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:self.navigationBar.tintColor};
    if (@available(iOS 11.0, *)) {
        self.navigationBar.prefersLargeTitles = prefersLargeTitle;
        self.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName:self.navigationBar.tintColor};
    }
}


#pragma mark -
#pragma mark UINavigationBarDelegate
#pragma mark -

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if (self.viewControllers.count < navigationBar.items.count) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    if ([self.topViewController respondsToSelector:@selector(controllerShouldPop)]) {
        shouldPop = self.topViewController.controllerShouldPop;
    }
    
    if (shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    
    return NO;
}

@end
