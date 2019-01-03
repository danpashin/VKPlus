//
//  VKPlusImageCache.h
//  VKPlusPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKPlusImageCache : NSObject

+ (void)saveImage:(UIImage *)image forKey:(NSString *)key;

+ (UIImage * _Nullable)cachedImageForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
