//
//  VKParamsImages.h
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsImages : NSObject

@property (strong, nonatomic, readonly, class) UIColor *mainColor;
@property (strong, nonatomic, readonly, class) UIColor *secondaryColor;
@property (strong, nonatomic, readonly, class) UIColor *iconColor;

@property (strong, nonatomic, readonly, class) UIImage *addIcon;
+ (UIImage *)addIconWithSize:(CGSize)size;

+ (void)executeBlock:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
