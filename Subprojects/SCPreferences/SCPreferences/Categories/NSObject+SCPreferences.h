//
//  NSObject+SCPreferences.h
//  SCPreferences
//
//  Created by Даниил on 10/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SCPreferences)

/**
 *  Асинхронно выполняет блок типа void на главном потоке.
 */
+ (void)sc_runAsyncBlockOnMainThread:(void(^)(void))block;

/**
 *  Выполняет заданный селектор у объекта. Является аналогом objc_msgSend.
 *  
 *  @param selector Селектор обьекта
 *  @param argument Список аргументов для выполения. Может быть nil, если селектор не принимает аргументов
 *
 *  @return Возвращает значение выполняемого селектора
 */
- (nullable void *)sc_executeSelector:(SEL)selector arguments:(nullable id)argument, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  Выполняет заданный селектор у объекта. Является аналогом objc_msgSend.
 *  
 *  @param selector Селектор обьекта
 *
 *  @return Возвращает значение выполняемого селектора
 */
- (nullable void *)sc_executeSelector:(SEL)selector;


/**
 *  Выполняет декодирование всех пропертей объекта
 */
- (void)sc_decodeObjectsWithCoder:(NSCoder *)aDecoder;

/**
 *  Выполняет кодирование всех пропертей объекта
 */
- (void)sc_encodeObjectsWithCoder:(NSCoder *)aCoder;


@end

NS_ASSUME_NONNULL_END
