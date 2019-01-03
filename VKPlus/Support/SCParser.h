//
//  SCParser.h
//  SCParser
//
//  Created by Даниил on 01.05.18.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Блок, который вызывается после завершения парсинга.

 @param plist Содержит словарь с обработанными данными. Если парсинг прошел неудачно, вернет nil.
 @param error Вернет ошибку, если парсинг прошел неудачно.
 */
typedef void(^SCParserCompletion)(NSDictionary * _Nullable plist, NSError * _Nullable error);



NS_ASSUME_NONNULL_BEGIN

@interface SCParser : NSObject

/**
 Выполняет парсинг встроенного в приложение профиля mobileprovision.
 Таковой имеется только в самоподписанных приложениях.

 @param completion Блок, который вызывается после завершения парсинга.
 @see SCParserCompletion
 */
- (void)parseAppProvisionWithCompletion:(SCParserCompletion)completion;


/**
 Выполняет парсинг данных, подписанных с помощью цифрового сертификата.

 @param signedData Данные для парсинга.
 
 @param completion Блок, который вызывается после завершения парсинга.
 @see SCParserCompletion
 */
- (void)parseSignedData:(NSData *)signedData completion:(SCParserCompletion)completion;

@end

NS_ASSUME_NONNULL_END
