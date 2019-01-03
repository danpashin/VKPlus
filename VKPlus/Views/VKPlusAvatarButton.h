//
//  VKPlusAvatarButton.h
//  VKPlus
//
//  Created by Даниил on 06/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKPlusAvatarButton : UIButton

+ (instancetype)buttonWithFrame:(CGRect)frame userID:(NSNumber *)userID;

@end

NS_ASSUME_NONNULL_END
