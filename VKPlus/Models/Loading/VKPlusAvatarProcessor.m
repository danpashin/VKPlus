//
//  VKPlusAvatarProcessor.m
//  VKPlus
//
//  Created by Даниил on 28/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusAvatarProcessor.h"
#import "VKPlusImageCache.h"

@interface VKPlusAvatarProcessor ()
@property (strong, nonatomic) dispatch_queue_t backgroundQueue;
@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *avatarURL;
@property (assign, nonatomic) CGSize resizeSize;

@property (copy, nonatomic) void (^completionHandler)(UIImage * _Nullable avatar);
@end

@implementation VKPlusAvatarProcessor

+ (void)processAvatarForUser:(NSNumber *)userID url:(NSString *)url size:(CGSize)size completionHandler:( void (^)(UIImage * _Nullable avatar) )completionHandler
{
    VKPlusAvatarProcessor *processor = [VKPlusAvatarProcessor new];
    processor.userID = userID;
    processor.avatarURL = url;
    processor.resizeSize = size;
    processor.completionHandler = completionHandler;
    [processor start];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundQueue = dispatch_queue_create("ru.danpashin.vkplusplus.image.processing.background", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)start
{
    NSString *cacheName = [NSString stringWithFormat:@"ava_%@_%.0fx%.0f", self.userID, self.resizeSize.width, self.resizeSize.height];
    dispatch_async(self.backgroundQueue, ^{
        UIImage *cachedImage = [VKPlusImageCache cachedImageForKey:cacheName];
        if (cachedImage) {
            self.completionHandler(cachedImage);
        }
        
        [self downloadDataFromURL:self.avatarURL success:^(NSHTTPURLResponse * _Nonnull httpResponse, NSData * _Nonnull rawData) {
            dispatch_async(self.backgroundQueue, ^{
                UIImage *rawImage = [UIImage imageWithData:rawData];
                if (rawImage) {
                    rawImage = [self resizeImage:rawImage];
                    rawImage = [self circledImage:rawImage];
                    
                    self.completionHandler(rawImage);
                    
                    [VKPlusImageCache saveImage:rawImage forKey:cacheName];
                }
            });
        } failure:nil];
    });
}

- (UIImage *)resizeImage:(UIImage *)image
{
    @autoreleasepool {
        UIImage *resizedImage = [image copy];
        
        CGSize size = self.resizeSize;
        size.width = ceilf((float)size.width);
        size.height = ceilf((float)size.height);
        
        UIGraphicsBeginImageContextWithOptions(resizedImage.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (resizedImage.imageOrientation == UIImageOrientationRight) {
            CGContextRotateCTM(context, (CGFloat)(90 * M_PI/180.0f));
        } else if (resizedImage.imageOrientation == UIImageOrientationLeft) {
            CGContextRotateCTM(context, (CGFloat)(-90 * M_PI/180.0f));
        } else if (resizedImage.imageOrientation == UIImageOrientationUp) {
            CGContextRotateCTM(context, (CGFloat)(180 * M_PI/180.0f));
        }
        [resizedImage drawAtPoint:CGPointZero];
        
        CGImageRef imgRef = CGBitmapContextCreateImage(context);
        UIGraphicsEndImageContext();
        
        CGFloat original_width  = CGImageGetWidth(imgRef);
        CGFloat original_height = CGImageGetHeight(imgRef);
        CGImageRelease(imgRef);
        
        CGFloat width_ratio = size.width / original_width;
        CGFloat height_ratio = size.height / original_height;
        CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
        
        CGRect bounds =  CGRectMake(0.0f, 0.0f, (CGFloat)round(original_width * scale_ratio), (CGFloat)round(original_height * scale_ratio));
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
        [resizedImage drawInRect:bounds];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake ((resizedImage.size.width - size.width) / 2, (resizedImage.size.height - size.height) / 2, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(cropRect.size, NO, [UIScreen mainScreen].scale);
        CGContextClipToRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
        [resizedImage drawInRect:CGRectMake(-cropRect.origin.x, -cropRect.origin.y, resizedImage.size.width, resizedImage.size.height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resizedImage;
    }
}

- (UIImage *)circledImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(context, image.size.width / 2.0f, image.size.height / 2.0f, image.size.width / 2.0f, 0, (CGFloat)(2.0f * M_PI), 0);
    CGContextClip(context);
    
    [image drawInRect:(CGRect){{0,0}, image.size}];
    UIImage *circledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circledImage;
}

@end
