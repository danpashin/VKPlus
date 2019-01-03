//
//  SCAlertController.h
//  SCPreferences
//
//  Created by Даниил on 09.07.17.
//
//

#import <UIKit/UIAlertController.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCAlertController : UIAlertController

+ (instancetype)actionSheetWithMessage:(nullable NSString *)message;
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

- (void)addTextFieldWithConfigurationHandler:(nullable void (^)(UITextField *textField))configurationHandler;
- (void)addAction:(UIAlertAction *)action image:(NSString *)imageName;

- (void)addCancelAction;
- (void)addCancelActionWithTitle:(NSString *)title;

- (void)present;
- (void)presentFromController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
