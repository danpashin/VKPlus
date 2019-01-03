//
//  VKPlusAvatarProcessor.h
//  VKPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKPlusAvatarProcessor : VKPlusNetwork

+ (void)processAvatarForUser:(NSNumber *)userID url:(NSString *)url size:(CGSize)size completionHandler:( void (^)(UIImage *_Nullable avatar) )completionHandler;

@end

NS_ASSUME_NONNULL_END
