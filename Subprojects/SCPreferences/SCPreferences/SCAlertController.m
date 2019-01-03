//
//  SCAlertController.m
//  SCPreferences
//
//  Created by Даниил on 09.07.17.
//
//

#import "SCAlertController.h"
#import <UIKit/UIKit.h>

#define SC_UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

@interface UIAlertAction ()
@property (nonatomic) UIImage *image;
@end

@implementation SCAlertController

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message
{
    return [self alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
}

+ (instancetype)actionSheetWithMessage:(nullable NSString *)message
{
    return [self alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
}

- (void)addTextFieldWithConfigurationHandler:(nullable void (^)(UITextField *textField))configurationHandler
{
    __weak typeof(self) weakSelf = self;
    [super addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField){
        [weakSelf setupTextField:textField];
        if (configurationHandler)
            configurationHandler(textField);
    }];
}

- (void)setupTextField:(UITextField *)textField
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *viewToRoundSuperView = textField.superview.superview;
        if (viewToRoundSuperView) {
            for (UIView *subview in textField.superview.superview.subviews) {
                subview.backgroundColor = [UIColor clearColor];
                if ([subview isKindOfClass:[UIVisualEffectView class]])
                    subview.hidden = YES;
            }
            UIView *viewToRound = textField.superview;
            textField.backgroundColor = [UIColor whiteColor];
            viewToRound.backgroundColor = [UIColor whiteColor];
            viewToRound.layer.cornerRadius = 5.0f;
            viewToRound.layer.borderWidth = 0.5f;
            viewToRound.layer.borderColor = [UIColor colorWithWhite:0.85f alpha:1.0f].CGColor;
            viewToRound.layer.masksToBounds = YES;
        }
    });
}

- (void)present
{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (viewController.presentedViewController)
        viewController = viewController.presentedViewController;
    
    [self presentFromController:viewController];
}

- (void)presentFromController:(UIViewController *)viewController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.permittedArrowDirections = 0;
        self.popoverPresentationController.sourceView = viewController.view;
        self.popoverPresentationController.sourceRect = viewController.view.bounds;
        
        [viewController presentViewController:self animated:YES completion:nil];
    });
}

- (void)addAction:(UIAlertAction *)action image:(NSString *)imageName
{
    if ([action respondsToSelector:@selector(setImage:)] && imageName.length > 0) {
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        action.image = image;
    }
    [super addAction:action];
}

- (void)addCancelAction
{
    [self addCancelActionWithTitle:SC_UIKitLocalizedString(@"Cancel")];
}

- (void)addCancelActionWithTitle:(NSString *)title
{
    [self addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
}

@end
