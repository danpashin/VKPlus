//
//  VKParamsProxyModel.m
//  VKParams
//
//  Created by Даниил on 22/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsProxyModel.h"

@implementation VKParamsProxyModel

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = VKParamsProxyTypeHTTPS;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self sc_decodeObjectsWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self sc_encodeObjectsWithCoder:aCoder];
}

- (NSString *)identifier
{
    return [self proxyIDForType:self.type];
}

- (NSString *)protocol
{
    if (self.type == VKParamsProxyTypeHTTPS) return @"HTTPS";
    else if (self.type == VKParamsProxyTypeSOCKS5) return @"SOCKS5";
    
    return @"Unknown";
}


- (NSString *)proxyIDForType:(VKParamsProxyType)type
{
    if (type == VKParamsProxyTypeHTTPS) return @"proxyTypeHTTPS";
    else if (type == VKParamsProxyTypeSOCKS5) return @"proxyTypeSOCKS5";
    
    return @"proxyTypeUnknown";
}

- (VKParamsProxyType)proxyTypeForID:(NSString *)proxyID
{
    if ([proxyID isEqualToString:[self proxyIDForType:VKParamsProxyTypeHTTPS]]) return VKParamsProxyTypeHTTPS;
    else if ([proxyID isEqualToString:[self proxyIDForType:VKParamsProxyTypeSOCKS5]]) return VKParamsProxyTypeSOCKS5;
    
    return VKParamsProxyTypeUnknown;
}

- (NSString *)host
{
    if (!_host) {
        _host = @"";
    }
    return _host;
}

- (NSString *)port
{
    if (!_port) {
        _port = @"";
    }
    return _port;
}

- (NSString *)login
{
    if (!_login) {
        _login = @"";
    }
    return _login;
}

- (NSString *)password
{
    if (!_password) {
        _password = @"";
    }
    return _password;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[VKParamsProxyModel class]])
        return NO;
    
    VKParamsProxyModel *proxyModel = object;
    if (![proxyModel.host isEqualToString:self.host] 
        || ![proxyModel.port isEqual:self.port] 
        || ![proxyModel.login isEqual:self.login] 
        || ![proxyModel.password isEqual:self.password] 
        || (proxyModel.type != self.type)
        ){
        return NO;
    }
    
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> type: '%@'; server: '%@@%@:%@'; password: '%@'", 
            self.class, self, [self proxyIDForType:self.type],
             self.login, self.host, self.port, self.password];
}

@end
