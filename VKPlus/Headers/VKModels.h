//
//  VKModels.h
//  VKParams
//
//  Created by Даниил on 15/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

@interface NavigationStats : NSObject
@end

@interface DiscoverNavigationDelegate : NSObject <UINavigationControllerDelegate>
+ (id <UINavigationControllerDelegate>)delegateWithNavigationStats:(NavigationStats *)navigationStats;
@end

@interface VKSession : NSObject
@property (readonly, strong, nonatomic) NavigationStats *navigationStats;
@end

@interface Model : NSObject
@property (readonly, strong, nonatomic) VKSession *session;
@end


@interface MenuModel : Model
- (instancetype)initWithSession:(VKSession *)session;
@end

@interface MainModel : Model
//- (id)profileStatistics;
//- (__kindof UIViewController *)accountBanned;  // Черный список
@end


@interface VKPhoto : NSObject
@property(retain, nonatomic) NSMutableDictionary <NSNumber *, id> *variants;
@end

@interface VKLink : NSObject
@property(retain, nonatomic) VKPhoto *photo;
@end

@interface VKDoc : NSObject
@property (strong, nonatomic) NSMutableDictionary *variants;
@end

@interface VKVideo : NSObject
@property (strong, nonatomic) NSMutableDictionary *firstFrameVariants;
@property (assign, nonatomic) BOOL no_autoplay;
@end


@interface VKAttachments : NSObject
@property (strong, nonatomic) NSMutableArray *attachments;
@end


@interface VKUser : NSObject
@property (strong, nonatomic) NSNumber *uid;
@property (strong, nonatomic, readonly) NSNumber *source_id;
@end


@interface VKUserProfile : NSObject
@property (assign, nonatomic) long long age;
@property (strong, nonatomic) VKUser *user;
@end


@interface VAColor : UIColor
+ (UIColor *)tabbarInactiveIcon;
+ (UIColor *)tabbarActiveIcon;
@end


@interface HTTPRequest : NSObject
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSDictionary *headers;
@end

