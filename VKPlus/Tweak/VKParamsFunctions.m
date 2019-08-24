//
//  VKParamsFunctions.m
//  VKParams
//
//  Created by Даниил on 12/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTweak.h"

#import "VKParamsTabbarModel.h"
#import "AFNetworking.h"
#import "VKPlusNetwork.h"
#import "VKParamsProxyModel.h"


VKMMainController *vkp_vkMainController;

extern BOOL disableAdultRestriction;
extern long long userAge;

NSURLRequest *requestWithProxyHeader(NSURLRequest *oldRequest)
{
    if (useProxy && proxyModel.type == VKParamsProxyTypeHTTPS) {
        NSMutableURLRequest *mutableRequest = [oldRequest isKindOfClass:[NSMutableURLRequest class]] ? oldRequest : [oldRequest mutableCopy];
        NSString *authenticationString = [NSString stringWithFormat:@"%@:%@", proxyModel.login, proxyModel.password];
        
        NSString *authenticationValue = [[authenticationString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        authenticationValue = [@"Basic " stringByAppendingString:authenticationValue];
        [mutableRequest setValue:authenticationValue forHTTPHeaderField:@"Proxy-Authorization"];
        
        return mutableRequest;
    }
    
    return oldRequest;
}

NSDictionary *defaultProxyDictionary(void)
{
    NSMutableDictionary *proxyDict = [NSMutableDictionary dictionary];
    
    if (useProxy && proxyModel.type == VKParamsProxyTypeHTTPS) {
        proxyDict[@"HTTPSEnable"] = @YES;
        proxyDict[@"HTTPSProxy"] = proxyModel.host;
        proxyDict[@"HTTPSPort"] = @(proxyModel.port.integerValue);
    }
    
    return proxyDict;
}

void updateMessagesBadge(void)
{
    [NSObject sc_runAsyncBlockOnMainThread:^{
        UITabBarItem *dialogsTabbarItem = vkp_vkMainController.dialogsController.navigationController.tabBarItem;
        if (hideMessagesBadge)
            dialogsTabbarItem.badgeValue = nil;
        else if (messageBadgeCustomText.length > 0)
            dialogsTabbarItem.badgeValue =  messageBadgeCustomText;
        else
            dialogsTabbarItem.badgeValue =  (cachedUnreadMessagesCount > 0) ? [NSString stringWithFormat:@"%lld", cachedUnreadMessagesCount] : nil;
        
    }];
}

NSString *defaultUserAgent(void)
{
    NSString *appBuildNumber = applicationBuildNumber;
    if (disableAdultRestriction) {
        appBuildNumber = @"12";
    }
    
    return [NSString stringWithFormat:@"com.vk.vkclient/%@ (unknown, iOS %@, iPhone, Scale/2.000000)",
            appBuildNumber, [[UIDevice currentDevice] systemVersion]];
}
