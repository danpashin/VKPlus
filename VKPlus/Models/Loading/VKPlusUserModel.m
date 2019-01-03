//
//  VKPlusUserModel.m
//  VKPlus
//
//  Created by Даниил on 06/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusUserModel.h"
#import "VKPlusAvatarProcessor.h"

@interface VKPlusUserModel ()
@end

@implementation VKPlusUserModel

+ (instancetype)modelForUserID:(NSNumber *)userID
{
    return [[self alloc] initWithUserID:userID];
}

- (instancetype)initWithUserID:(NSNumber *)userID
{
    self = [super init];
    if (self) {
        _userID = userID;
    }
    return self;
}

- (void)updateWithCompletion:(void(^_Nullable)(void))completion
{
    NSString *url = @"https://api.vk.com/method/users.get";
    NSDictionary *params = @{@"access_token":appAccessToken, @"user_ids":self.userID, @"fields":@"photo_100", @"v":@"5.88"};
    [self sendJSONRequestWithMethod:VKPlusNetworkMethodTypePOST url:url parameters:params success:^(NSURLRequest * _Nullable request, NSHTTPURLResponse * _Nullable httpResponse, NSDictionary * _Nullable json) {
        NSDictionary *response = ((NSArray *)json[@"response"]).firstObject;
        self->_avatarURL = response[@"photo_100"];
        
        if (completion)
            completion();
    } failure:^(NSURLRequest * _Nullable request, NSHTTPURLResponse * _Nullable httpResponse, NSError * _Nullable error) {
        self->_avatarURL = nil;
        
        if (completion)
            completion();
    }];
}

- (void)loadAvatarWithCompletion:(void(^)(UIImage * _Nullable avatar))completion
{
    [self loadAvatarWithSize:CGSizeMake(200.0f, 200.0f) completion:completion];
}

- (void)loadAvatarWithSize:(CGSize)size completion:(void(^)(UIImage * _Nullable avatar))completion
{
    [VKPlusAvatarProcessor processAvatarForUser:self.userID url:self.avatarURL size:size completionHandler:completion];
}

@end
