//
//  AFNetworking.h
//  VKParams
//
//  Created by Даниил on 20/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

@interface AFURLConnectionOperation : NSOperation
@property (strong, nonatomic) NSData *responseData;
@property (strong, nonatomic) NSURLRequest *request;
@end

@interface AFHTTPRequestOperation : AFURLConnectionOperation

- (instancetype)initWithRequest:(NSURLRequest *)request;
- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success 
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

@interface AFJSONRequestOperation : AFHTTPRequestOperation

+ (AFJSONRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)request 
                                                    success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success 
                                                    failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure;
@property (strong, nonatomic) id responseJSON;

@end
