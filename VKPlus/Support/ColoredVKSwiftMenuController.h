//
//  ColoredVKSwiftMenuController.h
//  ColoredVK2
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ColoredVKSwiftMenuItemsGroup;

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKSwiftMenuController : UIViewController

/**
 Получает контроллер меню, который был использован для регистрации ForceTouch.

 @param viewController Контроллер, который был зарегистрирован.
 @return Вернет контроллер меню, если регистрация была выполнена. В ином случае вернет nil.
 */
+ (nullable instancetype)menuControllerForController:(__kindof UIViewController *)viewController;


@property (strong, nonatomic, null_resettable) NSMutableArray <ColoredVKSwiftMenuItemsGroup *> *itemsGroups;

- (instancetype)initWithParentViewController:(__kindof UIViewController * _Nullable)parentViewController NS_DESIGNATED_INITIALIZER;

/**
 Выполняет представление контроллера на экране.
 В качестве ролительского контроллера выступает последний контроллер, который был представлен.
 */
- (void)present;

- (void)dismiss;

/**
 Выполняет регистрацию вью для использования ForceTouch.

 @param sourceView Вью, который будет исходным для представления.
 */
- (void)registerForceTouchForView:(UIView *)sourceView;

/**
 Выполняет регистрацию вью для представления с помощью длительного нажатия.

 @param view Вью, который будет зарегистрирован для нажатия.
 */
- (void)registerLongPressForView:(UIView *)view;



@property (weak, nonatomic, nullable) UIViewController *viewController DEPRECATED_ATTRIBUTE;
- (instancetype)initWithViewController:(UIViewController *)viewController andView:(UIView *)view DEPRECATED_MSG_ATTRIBUTE("Use -initWithParentViewController: instead.");

@end

NS_ASSUME_NONNULL_END
