//
//  VKParamsFunctions.h
//  VKParams
//
//  Created by Даниил on 12/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

@class VKMMainController, AFJSONRequestOperation;

extern VKMMainController *vkp_vkMainController;

extern void reloadPrefs(void);

extern NSURLRequest *requestWithProxyHeader(NSURLRequest *oldRequest);
extern NSDictionary *defaultProxyDictionary(void);

extern void updateMessagesBadge(void);


extern NSString *defaultUserAgent(void);
