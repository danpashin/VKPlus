//
//  VKPlusUserModel.h
//  VKPlus
//
//  Created by Даниил on 06/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKPlusUserModel : VKPlusNetwork

+ (instancetype)modelForUserID:(NSNumber *)userID;

@property (copy, nonatomic, readonly) NSNumber *userID;
@property (copy, nonatomic, readonly, nullable) NSString *avatarURL;

- (void)updateWithCompletion:(void(^_Nullable)(void))completion;


- (void)loadAvatarWithCompletion:(void(^)(UIImage * _Nullable avatar))completion;
- (void)loadAvatarWithSize:(CGSize)size completion:(void(^)(UIImage * _Nullable avatar))completion;

@end

NS_ASSUME_NONNULL_END
