//
//  VKPlusImageCache.m
//  VKPlusPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusImageCache.h"

@interface VKPlusImageCache ()

@property (strong, nonatomic, readonly, class) NSString *defaultCacheDirectory;

@end

@implementation VKPlusImageCache

+ (void)saveImage:(UIImage *)image forKey:(NSString *)key
{
    NSString *fullPath = [self.defaultCacheDirectory stringByAppendingString:key];
    
    UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:image.imageOrientation];
    [UIImagePNGRepresentation(newImage) writeToFile:fullPath atomically:YES];
}

+ (UIImage * _Nullable)cachedImageForKey:(NSString *)key
{
    NSString *fullPath = [self.defaultCacheDirectory stringByAppendingString:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSData *imageData = [NSData dataWithContentsOfFile:fullPath];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image)
            return [UIImage imageWithCGImage:image.CGImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
    }
    
    return nil;
}

+ (NSString *)defaultCacheDirectory
{
    NSString *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    cacheDirectory = [NSString stringWithFormat:@"%@/%@/", cacheDirectory, productBundleIdentifier];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return cacheDirectory;
}

@end
