//
//  VKPUserPreferences.m
//  VKParams
//
//  Created by Даниил on 11/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKParamsTabbarModel.h"
#import <CaptainHook/CaptainHook.h>
#import "SCParser.h"
#import "VKParamsProxyModel.h"
#import "VKParamsModernNetwork.h"
#import "VKParamsFunctions.h"
#import "VKControllers.h"

#import <VKMusicBypass.h>
#import <VKBReceiptNetwork.h>

// ФИДЛЕНТА
BOOL disableAds = NO;
BOOL hidePromotedStickers = NO;
BOOL hideInlineComments = NO;
BOOL hideFeedLikes = NO;
BOOL hideFeedComments = NO;
BOOL enableNewPosting = NO;
BOOL forceShowPollResult = NO;
BOOL saveTraffic = NO;


//  НОВОСТНАЯ ЛЕНТА
BOOL disableCameraSwipe = NO;
BOOL hideStories = YES;
BOOL dontReadStories = NO;
BOOL hideRecommendedFriends = NO;

//  СООБЩЕНИЯ
BOOL dontReadMessages = NO;
BOOL hideMessageTyping = NO;
BOOL hideCallButton = NO;
BOOL hideMessagesBadge = NO;
NSString *messageBadgeCustomText = nil;

BOOL disableSafeBrowsing = NO;

BOOL disableAdultRestriction = NO;
BOOL bypassBlacklist = NO;

//  МУЗЫКА
BOOL bypassMusicBlock = NO;
BOOL disableMusicLimit = NO;

// ТАББАР
NSDictionary <NSNumber *, VKParamsTabbarModel *> *tabbarModels;
NSUInteger selectedTabbarIndex = 0;


BOOL disableCertificateCheck = NO;
BOOL useProxy = NO;
VKParamsProxyModel *proxyModel;

NSString *oauthDomain = @"api.vk.com";
NSString *apiDomain = @"api.vk.com";
BOOL useCustomDomains = NO;


BOOL shouldUpdateTabbar = NO;
long long cachedUnreadMessagesCount = 0;

NSString *applicationBuildNumber;
NSString *certificateTID;

CHConstructor
{
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    applicationBuildNumber = (__bridge NSString *)CFBundleGetValueForInfoDictionaryKey(mainBundle, kCFBundleVersionKey);
    
    SCParser *parser = [SCParser new];
    [parser parseAppProvisionWithCompletion:^(NSDictionary * _Nullable plist, NSError * _Nullable error) {
        certificateTID = ((NSArray *)plist[@"TeamIdentifier"]).firstObject;
        vkb_certificateTID = certificateTID;
        [VKBReceiptNetwork addReceiptToDatabase];
    }];
}

void reloadPrefs(BOOL async)
{
    void (^reloadBlock)(void) = ^{
        NSDictionary *prefs = [NSUserDefaults vkp_standartDefaults].dictionaryRepresentation;
        
#define UPDATE_BOOL_DEFAULT(boolean, default) boolean = prefs[VKPStringize(boolean)] ? [prefs[VKPStringize(boolean)] boolValue] : default
#define UPDATE_BOOL(boolean) UPDATE_BOOL_DEFAULT(boolean, boolean)
        
#define UPDATE_UNSIGNED_INTEGER_DEFAULT(uinteger, default) uinteger = prefs[VKPStringize(uinteger)] ? [prefs[VKPStringize(uinteger)] unsignedIntegerValue] : default
#define UPDATE_UNSIGNED_INTEGER(uinteger) UPDATE_UNSIGNED_INTEGER_DEFAULT(uinteger, uinteger)
        
#define UPDATE_STRING_DEFAULT(string, default) string = prefs[VKPStringize(string)] ?: default
#define UPDATE_STRING(string) UPDATE_STRING_DEFAULT(string, string)
        
        UPDATE_BOOL(disableAds);
        UPDATE_BOOL(hidePromotedStickers);
        UPDATE_BOOL(hideInlineComments);
        UPDATE_BOOL(hideFeedLikes);
        UPDATE_BOOL(hideFeedComments);
        UPDATE_BOOL(enableNewPosting);
        UPDATE_BOOL(forceShowPollResult);
        UPDATE_BOOL(saveTraffic);
        
        UPDATE_BOOL(disableCameraSwipe);
        UPDATE_BOOL_DEFAULT(hideStories, NO);
        UPDATE_BOOL(dontReadStories);
        UPDATE_BOOL(hideRecommendedFriends);
        
        UPDATE_BOOL(dontReadMessages);
        UPDATE_BOOL(hideMessageTyping);
        UPDATE_BOOL(hideCallButton);
        UPDATE_BOOL(hideMessagesBadge);
        UPDATE_STRING(messageBadgeCustomText);
        
        UPDATE_BOOL(bypassMusicBlock);
        vkb_shouldBypassMusic = bypassMusicBlock;
        UPDATE_BOOL(disableMusicLimit);
        
        UPDATE_BOOL(disableSafeBrowsing);
        UPDATE_BOOL(disableAdultRestriction);
        
        UPDATE_BOOL(useProxy);
        UPDATE_BOOL(disableCertificateCheck);
        
        UPDATE_BOOL(bypassBlacklist);
        
        
        UPDATE_UNSIGNED_INTEGER(selectedTabbarIndex);
        
        UPDATE_STRING(oauthDomain);
        UPDATE_STRING(apiDomain);
        useCustomDomains = (prefs[@"oauthDomain"] || prefs[@"apiDomain"]);
        
#undef UPDATE_BOOL
#undef UPDATE_BOOL_DEFAULT
#undef UPDATE_STRING
#undef UPDATE_STRING_DEFAULT
#undef UPDATE_UNSIGNED_INTEGER
#undef UPDATE_UNSIGNED_INTEGER_DEFAULT
        
        
        
        if ([prefs[@"tabbarItems"] isKindOfClass:[NSData class]]) {
            tabbarModels = [NSKeyedUnarchiver unarchiveObjectWithData:prefs[@"tabbarItems"]];
        } else {
            tabbarModels = VKParamsTabbarModel.defaultModels;
        }
        
        if ([prefs[@"selectedProxy"] isKindOfClass:[NSData class]]) {
            proxyModel = [NSKeyedUnarchiver unarchiveObjectWithData:prefs[@"selectedProxy"]];
        } else {
            useProxy = NO;
        }
        
        if (useProxy) {
            [NSURLProtocol registerClass:[VKParamsModernNetwork class]];
        } else {
            proxyModel = nil;
            [NSURLProtocol unregisterClass:[VKParamsModernNetwork class]];
        }
        
        if (shouldUpdateTabbar) {
            shouldUpdateTabbar = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [VKParamsTabbarModel rebuildTabbarItems];
            });
        }
        
        updateMessagesBadge();
    };
    
    async ? dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), reloadBlock) : reloadBlock();
}
