//
//  VKPlusBlacklist.h
//  VKPlus
//
//  Created by Даниил on 21/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFJSONRequestOperation, AFJSONRequestOperation;


NS_ASSUME_NONNULL_BEGIN

extern NSInteger wallRequestPostsCount;

@interface VKPlusBlacklist : NSObject

+ (void)makeProfileRequestWithOperation:(AFJSONRequestOperation *)operation origResponse:(NSDictionary *)origResponse 
                                success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success
                                failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure;

+ (void)makeWallRequestWithOperation:(AFJSONRequestOperation *)operation origResponse:(NSDictionary *)origResponse 
                             success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure;

+ (void)makeCommentsRequestWithOperation:(AFJSONRequestOperation *)operation origResponse:(NSDictionary *)origResponse 
                                 success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success
                                 failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
