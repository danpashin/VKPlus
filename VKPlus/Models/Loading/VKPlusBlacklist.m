//
//  VKPlusBlacklist.m
//  VKPlus
//
//  Created by Даниил on 21/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusBlacklist.h"
#import "AFNetworking.h"
#import <objc/runtime.h>

NSInteger wallRequestPostsCount = 0;
@implementation VKPlusBlacklist

+ (void)makeProfileRequestWithOperation:(AFJSONRequestOperation *)operation origResponse:(NSDictionary *)origResponse 
                                success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success
                                failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure
{
    NSURL *apiURL = [NSURL URLWithString:@"https://api.vk.com/method/groups.getById"];;
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:apiURL cachePolicy:operation.request.cachePolicy timeoutInterval:operation.request.timeoutInterval];
    newRequest.HTTPMethod = @"POST";
    newRequest.allHTTPHeaderFields = operation.request.allHTTPHeaderFields;
    
    NSString *stringBody = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding];
    NSArray <NSString *> *allArguments = [stringBody.stringByRemovingPercentEncoding componentsSeparatedByString:@"&"];
    
    __block NSString *groupID = nil;
    __block NSString *apiVersion = nil;
    [allArguments enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger equalLocation = [obj rangeOfString:@"="].location;
        if (equalLocation != NSNotFound) {
            NSString *key = [obj substringToIndex:equalLocation];
            NSString *value = [obj substringFromIndex:equalLocation+1];
            if ([key isEqualToString:@"gid"])
                groupID = value;
            
            if ([key isEqualToString:@"v"])
                apiVersion = value;
        }
    }];
    
    NSString *newBody = [NSString stringWithFormat:@"group_id=%@&fields=audio_artist_id,status,counters,members_count,place,wiki_page,city,country,description,start_date,finish_date,site,can_post,can_see_all_posts,can_suggest,verified,trending,is_adult,is_favorite,is_subscribed,ban_info,can_message,can_create_topic,market,public_date_label,contacts,can_upload_video,links,app_button,app_buttons,cover,is_messages_blocked,video_live,main_section,can_upload_story,has_market_app,vkpay_can_transfer,using_vkpay_market_app,addresses,action_button,buttons,phone,author_id&access_token=%@&v=%@", groupID, appAccessToken, apiVersion];
    newRequest.HTTPBody = [newBody dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *requestOperation = [[objc_lookUpClass("AFHTTPRequestOperation") alloc] initWithRequest:newRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *newOperation, NSData *newResponseData) {
        NSDictionary *newResponseJSON = [NSJSONSerialization JSONObjectWithData:newResponseData options:0 error:nil];
        if (newResponseJSON) {
            NSDictionary *groupInfo = [newResponseJSON[@"response"] firstObject];
            if (groupInfo) {
                NSMutableDictionary *mutableReponseObject = [origResponse mutableCopy];
                NSMutableDictionary *mutableResponse = [mutableReponseObject[@"response"] mutableCopy];
                
                mutableResponse[@"grp"] = groupInfo;
                mutableReponseObject[@"response"] = mutableResponse;
                
                if (success) {
                    if ([operation respondsToSelector:@selector(responseJSON)])
                        operation.responseJSON = mutableReponseObject;
                    
                    success(operation, mutableReponseObject);
                    return;
                }
            }
        }
        
        if (success)
            success(operation, origResponse);
    } failure:^(AFHTTPRequestOperation *blockOperation, NSError *error) {
        if (failure)
            failure(operation, error);
    }];
    [requestOperation start];
}

+ (NSString *)getAPIVersionForURL:(NSURL *)url
{
    static NSString *apiVersion = nil;
    
    if (!apiVersion) {
        NSArray <NSString *> *allArguments = [url.absoluteString.stringByRemovingPercentEncoding componentsSeparatedByString:@"&"];
        [allArguments enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUInteger equalLocation = [obj rangeOfString:@"="].location;
            if (equalLocation != NSNotFound) {
                NSString *key = [obj substringToIndex:equalLocation];
                NSString *value = [obj substringFromIndex:equalLocation + 1];
                
                if ([key isEqualToString:@"v"])
                    apiVersion = value;
            }
        }];
    }
    
    return apiVersion;
}

+ (NSString *)createQueryFromDictionary:(NSDictionary *)dict
{
    NSMutableString *stringQuery = [NSMutableString string];
    for (NSString *key in [dict.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        [stringQuery appendFormat:@"%@=%@&", key, dict[key]];
    }
    
    if ([stringQuery hasSuffix:@"&"])
        [stringQuery replaceCharactersInRange:NSMakeRange(stringQuery.length - 1, 1) withString:@""];
    
    return stringQuery;
}

+ (void)makeWallRequestWithOperation:(AFJSONRequestOperation *)operation origResponse:(NSDictionary *)origResponse 
                             success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure
{
    NSURL *apiURL = [NSURL URLWithString:@"https://api.vk.com/method/wall.get"];;
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:apiURL cachePolicy:operation.request.cachePolicy timeoutInterval:operation.request.timeoutInterval];
    newRequest.HTTPMethod = @"POST";
    newRequest.allHTTPHeaderFields = operation.request.allHTTPHeaderFields;
    
    __block NSString *groupID = nil;
    NSString *apiVersion = [self getAPIVersionForURL:operation.request.URL];
    NSInteger offset = (wallRequestPostsCount > 0) ? wallRequestPostsCount + 25 : 0;
    NSInteger count = 25;
    
    
    NSString *origURL = operation.request.URL.absoluteString.stringByRemovingPercentEncoding;
    origURL = [origURL stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSError *groupIDRegexError = nil;
    NSRegularExpression *groupIDRegex = [NSRegularExpression regularExpressionWithPattern:@"(owner_id){1}(%3A|:){1}(-){0,1}(\\d){1,}"
                                                                                  options:NSRegularExpressionCaseInsensitive error:&groupIDRegexError];
    [groupIDRegex enumerateMatchesInString:origURL options:0 range:NSMakeRange(0, origURL.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSString *keyValueArgument = [origURL substringWithRange:match.range].stringByRemovingPercentEncoding;
        groupID = [keyValueArgument componentsSeparatedByString:@":"].lastObject;
        *stop = YES;
    }];
    
    if (groupID && apiVersion) {
        NSString *newBody = [NSString stringWithFormat:@"owner_id=%@&offset=%@&count=%@&extended=1&filter=all&fields=photo_100,sex,video_files,friend_status,verified,trending&access_token=%@&v=%@", 
                             groupID, @(offset), @(count), appAccessToken, apiVersion];
        newRequest.HTTPBody = [newBody dataUsingEncoding:NSUTF8StringEncoding];
        
        AFHTTPRequestOperation *requestOperation = [[objc_lookUpClass("AFHTTPRequestOperation") alloc] initWithRequest:newRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *newOperation, NSData *newResponseData) {
            NSDictionary *newResponseJSON = [NSJSONSerialization JSONObjectWithData:newResponseData options:0 error:nil];
            if (newResponseJSON) {
                NSMutableDictionary *wallInfo = [newResponseJSON[@"response"] mutableCopy];
                if (wallInfo) {
                    wallRequestPostsCount += 25;
                    wallInfo[@"next_from"] = @(wallRequestPostsCount);
                    
                    NSMutableDictionary *mutableReponseObject = [origResponse mutableCopy];
                    NSMutableDictionary *mutableResponse = [mutableReponseObject[@"response"] mutableCopy];
                    
                    mutableResponse[@"wall"] = wallInfo;
                    mutableReponseObject[@"response"] = mutableResponse;
                    
                    if (success) {
                        if ([operation respondsToSelector:@selector(responseJSON)])
                            operation.responseJSON = mutableReponseObject;
                        
                        success(operation, mutableReponseObject);
                        return;
                    }
                }
            }
            
            if (success)
                success(operation, origResponse);
        } failure:^(AFHTTPRequestOperation *blockOperation, NSError *error) {
            if (failure)
                failure(operation, error);
        }];
        [requestOperation start];
    } else if (success)
        success(operation, origResponse);
}


+ (void)makeCommentsRequestWithOperation:(AFJSONRequestOperation *)operation origResponse:(NSDictionary *)origResponse 
                             success:(void (^)(AFJSONRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFJSONRequestOperation *operation, NSError *error))failure
{
    __block NSMutableDictionary *getCommentsDict = [NSMutableDictionary dictionary];
    
    
    NSString *origURL = operation.request.URL.absoluteString.stringByRemovingPercentEncoding;
    
    NSRegularExpression *postIDRegex = [NSRegularExpression regularExpressionWithPattern:@"(getComments){1}(\\((.*?)\\))(;){1}"
                                                                                 options:NSRegularExpressionCaseInsensitive error:nil];
    [postIDRegex enumerateMatchesInString:origURL options:0 range:NSMakeRange(0, origURL.length) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSString *getCommentsFunction = [origURL substringWithRange:match.range];
        getCommentsFunction = [getCommentsFunction stringByReplacingOccurrencesOfString:@"getComments(" withString:@""];
        
        if ([getCommentsFunction hasSuffix:@");"])
            getCommentsFunction = [getCommentsFunction substringToIndex:getCommentsFunction.length-2];
        
        getCommentsDict = [NSJSONSerialization JSONObjectWithData:[getCommentsFunction dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        *stop = YES;
    }];
    
    if (getCommentsDict.count > 0) {
        getCommentsDict[@"v"] = [self getAPIVersionForURL:operation.request.URL];
        getCommentsDict[@"access_token"] = appAccessToken;
        
        NSURL *apiURL = [NSURL URLWithString:@"https://api.vk.com/method/wall.getComments"];;
        NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:apiURL cachePolicy:operation.request.cachePolicy 
                                                              timeoutInterval:operation.request.timeoutInterval];
        newRequest.HTTPMethod = @"POST";
        newRequest.allHTTPHeaderFields = operation.request.allHTTPHeaderFields;
        newRequest.HTTPBody = [[self createQueryFromDictionary:getCommentsDict] dataUsingEncoding:NSUTF8StringEncoding];
        
        AFHTTPRequestOperation *requestOperation = [[objc_lookUpClass("AFHTTPRequestOperation") alloc] initWithRequest:newRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *newOperation, NSData *newResponseData) {
            NSDictionary *newResponseJSON = [NSJSONSerialization JSONObjectWithData:newResponseData options:0 error:nil];
            
            if (newResponseJSON) {
                NSMutableDictionary *commentsInfo = [newResponseJSON[@"response"] mutableCopy];
                
                NSMutableDictionary *mutableReponseObject = [origResponse mutableCopy];
                NSMutableDictionary *mutableResponse = [mutableReponseObject[@"response"] mutableCopy];
                
                mutableResponse[@"comments"] = commentsInfo;
                mutableReponseObject[@"response"] = mutableResponse;
                
                if (success) {
                    if ([operation respondsToSelector:@selector(responseJSON)])
                        operation.responseJSON = mutableReponseObject;
                    
                    success(operation, mutableReponseObject);
                    return;
                }
            }
            
            if (success)
                success(operation, origResponse);
        } failure:^(AFHTTPRequestOperation *blockOperation, NSError *error) {
            if (failure)
                failure(operation, error);
        }];
        [requestOperation start];
        
        return;
    } else if (success)
        success(operation, origResponse);
    
}

@end
