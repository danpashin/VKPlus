//
//  VKParams.m
//  VKParams
//
//  Created by Даниил on 10/08/2018.
//  Copyright (c) 2018 Даниил. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import "VKParamsTweak.h"
#import "VKParamsTabbarModel.h"
#import "AFNetworking.h"
#import "VKParamsProxyModel.h"
#import "VKParamsMainPreferences.h"
#import "VKPlusBlacklist.h"
#import "UITableViewCell+VKPlus.h"



CHDeclareClass(AppDelegate);
CHDeclareMethod(2, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
   reloadPrefs(NO);
   
   BOOL orig = CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
   return orig;
}


CHDeclareClass(VKMMainController);
CHDeclareMethod(1, void, VKMMainController, viewDidAppear, BOOL, animated)
{
   CHSuper(1, VKMMainController, viewDidAppear, animated);
   
   static BOOL swiftMenuAdded = NO;
   if (!swiftMenuAdded) {
      swiftMenuAdded = [VKParamsTabbarModel setupQuickMenuController];
   }
}




CHDeclareClass(VKUtil);
CHDeclareClassMethod(4, id, VKUtil, safeBrowserURL, id, url, awayToken, id, awayToken, ref, id, ref, awayParams, id, awayParams)
{
   if (disableSafeBrowsing)
      return url;
   
   return CHSuper(4, VKUtil, safeBrowserURL, url, awayToken, awayToken, ref, ref, awayParams, awayParams);
}



__strong NSNumber *currentUserID;
CHDeclareClass(VKSession);
CHDeclareMethod(1, void, VKSession, setSessionUser, VKUserProfile *, userProfile)
{
   CHSuper(1, VKSession, setSessionUser, userProfile);
   
   currentUserID = [userProfile.user.uid copy];
   
   NSUserDefaults *userDefaults = [NSUserDefaults vkp_standartDefaults];
   [userDefaults setObject:currentUserID forKey:@"cachedUserID"];
}


CHDeclareClass(AFJSONRequestOperation);
CHDeclareClassMethod(3, AFJSONRequestOperation *, AFJSONRequestOperation, JSONRequestOperationWithRequest, NSURLRequest *, request, success, id, success, failure, id, failure)
{
   NSMutableURLRequest *mutableRequest = ([request isKindOfClass:[NSMutableURLRequest class]]) ? request : [request mutableCopy];
   
   if (![mutableRequest.URL.absoluteString containsString:@"apps.getVkApps"]) {
      NSString *userAgent = defaultUserAgent();
      [mutableRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
   }
   
   if (dontReadMessages && [mutableRequest.URL.absoluteString containsString:@"messages.markAsRead"])
      return nil;
   
   return CHSuper(3, AFJSONRequestOperation, JSONRequestOperationWithRequest, mutableRequest, success, success, failure, failure);
}


CHDeclareMethod(2, void, AFJSONRequestOperation, setCompletionBlockWithSuccess, id, success, failure, id, failure)
{
   if (bypassBlacklist) {
      void (^origSuccess)(AFJSONRequestOperation *operation, id responseObject) = [success copy];
      void (^origFailure)(AFJSONRequestOperation *operation, NSError *error) = [failure copy];
      
      success = ^(AFJSONRequestOperation *operation, id responseObject) {
         if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = responseObject[@"response"];
            if ([response isKindOfClass:[NSDictionary class]]) {
               
               BOOL isBlacklisted = NO;
               for (NSDictionary *errorDesc in responseObject[@"execute_errors"]) {
                  if ([errorDesc[@"error_code"] integerValue] == 15) {
                     isBlacklisted = YES;
                     break;
                  }
               }
               
               if (isBlacklisted && response[@"grp"]) {
                  [VKPlusBlacklist makeProfileRequestWithOperation:operation origResponse:responseObject 
                                                           success:origSuccess failure:origFailure];
                  return;
               } else if (isBlacklisted && response[@"profile"]) {
                  wallRequestPostsCount = 0;
                  [VKPlusBlacklist makeWallRequestWithOperation:operation origResponse:responseObject 
                                                        success:origSuccess failure:origFailure];
                  return;
               } else if (isBlacklisted && response[@"wall"]) {
                  [VKPlusBlacklist makeWallRequestWithOperation:operation origResponse:responseObject 
                                                        success:origSuccess failure:origFailure];
                  return;
               } else if (isBlacklisted && response[@"comments"]) {
                  [VKPlusBlacklist makeCommentsRequestWithOperation:operation origResponse:responseObject 
                                                        success:origSuccess failure:origFailure];
                  return;
               }
               
            }
         }
         
         if (origSuccess)
            origSuccess(operation, responseObject);
      };
   }
   
   
   return CHSuper(2, AFJSONRequestOperation, setCompletionBlockWithSuccess, success, failure, failure);
}

CHDeclareClass(HTTPClient);
CHDeclareMethod(1, id, HTTPClient, dataTaskWithRequest, id, request)
{
   NSString *url = nil;
   if ([request respondsToSelector:@selector(url)]) {
      url = [(HTTPRequest *)request url];
   } else if ([request respondsToSelector:@selector(URL)]) {
      url = [request URL].absoluteString;
   }
   
   if (dontReadMessages && [url containsString:@"messages.markAsRead"]) {
      return nil;
   }
   
   if (![url.lowercaseString containsString:@"apps"]) {
      NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
      if ([request isKindOfClass:objc_lookUpClass("HTTPRequest")]) {
         HTTPRequest *httpRequest = request;
         [mutableHeaders addEntriesFromDictionary:httpRequest.headers];
         mutableHeaders[@"User-Agent"] = defaultUserAgent();
         httpRequest.headers = mutableHeaders;
      } else {
         NSMutableURLRequest *_request = [request mutableCopy];
         [mutableHeaders addEntriesFromDictionary:_request.allHTTPHeaderFields];
         mutableHeaders[@"User-Agent"] = defaultUserAgent();
         _request.allHTTPHeaderFields = mutableHeaders;
         request = _request;
      }
   }
   
   return CHSuper(1, HTTPClient, dataTaskWithRequest, request);
}

CHDeclareClass(NSMutableURLRequest);
CHDeclareMethod(2, void, NSMutableURLRequest, setValue, id, value, forHTTPHeaderField, NSString *, field)
{
   if ([field isEqualToString:@"Host"])
      return;

   CHSuper(2, NSMutableURLRequest, setValue, value, forHTTPHeaderField, field);
}

CHDeclareClass(VKClient);
CHDeclareClassMethod(0, NSArray <NSURL *> *, VKClient, vkHosts)
{
   return @[
            [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", apiDomain]]
            ];
}


CHDeclareClass(VKAccountInfoSubscriptions);
CHDeclareMethod(0, BOOL, VKAccountInfoSubscriptions, musicSubscriptionActive)
{
   if (disableMusicLimit)
      return YES;
   
   return CHSuper(0, VKAccountInfoSubscriptions, musicSubscriptionActive);
}

CHDeclareClass(VKAdAudioPlayer);
CHDeclareMethod(1, void, VKAdAudioPlayer, playAdAudioWithUrl, id, url)
{
   if (disableAds)
      return;
   
   CHSuper(1, VKAdAudioPlayer, playAdAudioWithUrl, url);
}


CHDeclareClass(SSLPinValidator);
CHDeclareMethod(2, BOOL, SSLPinValidator, trust, SecTrustRef, certificate, forDomain, id, domain)
{
   if (useProxy || disableCertificateCheck)
      return YES;
   
   return CHSuper(2, SSLPinValidator, trust, certificate, forDomain, domain);
}


CHDeclareClass(TSKPinningValidator);
CHDeclareMethod(2, long long, TSKPinningValidator, evaluateTrust, SecTrustRef, certificate, forHostname, id, hostname)
{
   if (useProxy || disableCertificateCheck)
      return 0;

   return CHSuper(2, TSKPinningValidator, evaluateTrust, certificate, forHostname, hostname);
}

CHDeclareClass(NSURLSession);
CHDeclareClassMethod(3, NSURLSession *, NSURLSession, sessionWithConfiguration, NSURLSessionConfiguration *, configuration, 
                     delegate, id, delegate, delegateQueue, NSOperationQueue *, queue)
{
   configuration.connectionProxyDictionary = defaultProxyDictionary();
   return CHSuper(3, NSURLSession, sessionWithConfiguration, configuration, delegate, delegate, delegateQueue, queue);;
}

CHDeclareClass(NSURLSessionTask);
CHDeclareMethod(4, id, NSURLSessionTask, initWithOriginalRequest, NSURLRequest *, originalRequest,
                updatedRequest, NSURLRequest *, updatedRequest, ident, NSUInteger, ident, session, NSURLSession *, session)
{
   originalRequest = requestWithProxyHeader(originalRequest);
   
   return CHSuper(4, NSURLSessionTask, initWithOriginalRequest, originalRequest,
                  updatedRequest, updatedRequest, ident, ident, session, session);
}

NSInteger settingsCellCount = 0;
CHDeclareClass(ModernSettingsController);
CHDeclareMethod(2, NSInteger, ModernSettingsController, tableView, UITableView *, tableView, numberOfRowsInSection, NSInteger, section)
{
   NSInteger rowsCount = CHSuper(2, ModernSettingsController, tableView, tableView, numberOfRowsInSection, section);
   if (section == 1) {
      settingsCellCount = rowsCount;
      rowsCount++;
   }
   return rowsCount;
}

CHDeclareMethod(2, UITableViewCell *, ModernSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
   if (indexPath.section == 1 && indexPath.row == settingsCellCount)
      return [UITableViewCell vkp_prefsMainCell];
   
   return  CHSuper(2, ModernSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);;
}

CHDeclareMethod(2, void, ModernSettingsController, tableView, UITableView*, tableView, didSelectRowAtIndexPath, NSIndexPath*, indexPath)
{
   CHSuper(2, ModernSettingsController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
   
   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
   if ([cell.reuseIdentifier isEqualToString:@"vkpSettingsCell"]) {
      [vkp_weakPreferences dismissViewControllerAnimated:NO completion:nil];
      preferencesTabbarIndex = vkp_vkMainController.selectedIndex;
      
      VKParamsMainPreferences *prefs = [VKParamsMainPreferences new];
      vkp_weakPreferences = prefs;
      [self.navigationController pushViewController:prefs animated:YES];
   }
}

CHDeclareClass(VKAPI);
CHDeclareClassMethod(0, NSURL *, VKAPI, authURL)
{
   return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/oauth/token", oauthDomain]];
}

CHDeclareClassMethod(0, NSURL *, VKAPI, apiURL)
{
   return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/method/", apiDomain]];
}
