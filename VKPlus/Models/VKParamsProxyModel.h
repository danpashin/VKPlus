//
//  VKParamsProxyModel.h
//  VKParams
//
//  Created by Даниил on 22/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VKParamsProxyType) {
    VKParamsProxyTypeUnknown = -1,
    VKParamsProxyTypeHTTPS,
    VKParamsProxyTypeSOCKS5
};

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsProxyModel : NSObject

@property (assign, nonatomic) VKParamsProxyType type;

@property (copy, nonatomic, null_resettable) NSString *host;
@property (copy, nonatomic, null_resettable) NSString *port;

@property (copy, nonatomic, null_resettable) NSString *login;
@property (copy, nonatomic, null_resettable) NSString *password;

@property (copy, nonatomic, readonly) NSString *identifier;
@property (copy, nonatomic, readonly) NSString *protocol;

- (NSString *)proxyIDForType:(VKParamsProxyType)type;
- (VKParamsProxyType)proxyTypeForID:(NSString *)proxyID;

@end

NS_ASSUME_NONNULL_END
