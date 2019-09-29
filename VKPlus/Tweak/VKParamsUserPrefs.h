//
//  VKParamsUserPrefs.h
//  VKParams
//
//  Created by Даниил on 11/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

@class VKParamsTabbarModel, VKParamsProxyModel;

extern void reloadPrefs(BOOL async);

// ФИДЛЕНТА
extern BOOL disableAds;
extern BOOL hidePromotedStickers;
extern BOOL hideInlineComments;
extern BOOL hideFeedLikes;
extern BOOL hideFeedComments;
extern BOOL enableNewPosting;
extern BOOL forceShowPollResult;
extern BOOL saveTraffic;


//  НОВОСТНАЯ ЛЕНТА
extern BOOL disableCameraSwipe;
extern BOOL hideStories;
extern BOOL dontReadStories;
extern BOOL hideRecommendedFriends;

//  СООБЩЕНИЯ
extern BOOL dontReadMessages;
extern BOOL hideMessageTyping;
extern BOOL hideCallButton;
extern BOOL hideMessagesBadge;
extern NSString *messageBadgeCustomText;

extern BOOL disableSafeBrowsing;

extern BOOL disableAdultRestriction;
extern BOOL bypassBlacklist;

//  МУЗЫКА
extern BOOL bypassMusicBlock;
extern BOOL disableMusicLimit;

extern VKParamsProxyModel *proxyModel;
extern BOOL disableCertificateCheck;
extern BOOL useProxy;

extern NSString *oauthDomain;
extern NSString *apiDomain;
extern BOOL useCustomDomains;

extern NSDictionary <NSNumber *, VKParamsTabbarModel *> *tabbarModels;
extern NSUInteger selectedTabbarIndex;
extern long long cachedUnreadMessagesCount;
extern BOOL shouldUpdateTabbar;
