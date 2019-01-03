//
//  ColoredVKSwiftMenuItem.h
//  ColoredVK2
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKSwiftMenuButton : NSObject

/**
 Дефолтная иконка кнопки
 */
@property (strong, nonatomic) UIImage *icon;

/**
 Цвет иконки в обычном состоянии.
 */
@property (strong, nonatomic) UIColor *unselectedTintColor;

/**
 Цвет иконки в выбранном состоянии.
 */
@property (strong, nonatomic) UIColor *selectedTintColor;

/**
 Состояние кнопки.
 */
@property (assign, nonatomic) BOOL selected;

@property (assign, nonatomic) BOOL canHighlight;

/**
 Описание кнопки, которое будет отображаться сверху окна.
 */
@property (copy, nonatomic) NSString *unselectedTitle;

/**
 Описание кнопки, которое будет отображаться сверху окна.
 */
@property (copy, nonatomic) NSString *selectedTitle;

/**
 Блок, который будет вызван при нажатии на кнопку.
 
 ВАЖНО! Блок выполняется в фоновом потоке! Чтобы поизвести любое изменение UI необходимо перейти в главный поток.
 */
@property (copy, nonatomic) void (^selectHandler)(ColoredVKSwiftMenuButton *menuButton);

@end





@interface ColoredVKSwiftMenuItemsGroup : NSObject

/**
 Имя группы
 */
@property (copy, nonatomic) NSString *name;

@property (strong, nonatomic, readonly) NSMutableArray <ColoredVKSwiftMenuButton *> *buttons;
- (instancetype)initWithButtons:(NSArray <ColoredVKSwiftMenuButton *> *)items NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
