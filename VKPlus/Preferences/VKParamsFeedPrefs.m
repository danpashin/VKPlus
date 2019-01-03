//
//  VKParamsFeedPrefs.m
//  VKParams
//
//  Created by Даниил on 13/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsFeedPrefs.h"

@interface VKParamsFeedPrefs ()

@end

@implementation VKParamsFeedPrefs

- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = [self parseSpecifiersForArray:@[
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Disable_ads_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable ads", @"key":@"disableAds", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"hide_promoted_stickers_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"hide_promoted_stickers", @"key":@"hidePromotedStickers", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Hide_friends_likes_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Hide friend's likes", @"key":@"hideFeedLikes", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Hide_featured_comments_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Hide featured comments", @"key":@"hideFeedComments", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Disable_inline_comments_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable inline comments", @"key":@"hideInlineComments", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Show_poll_results_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Show poll results", @"key":@"forceShowPollResult", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Disable_left_side_swipe_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable left side swipe", @"key":@"disableCameraSwipe", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Disable_recommended_friends_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable recommended friends", @"key":@"hideRecommendedFriends", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Save_traffic_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Save traffic", @"key":@"saveTraffic", @"default":@NO
                                                        },
//                                                      @{@"cellType":@"group", @"label": @"Creating posts",
//                                                        @"footerText": @"Enable_new_design_footer"
//                                                        },
//                                                      @{@"cellType":@"Switch", @"label":@"Enable new design", @"key":@"enableNewPosting", @"default":@NO
//                                                        },
                                                      @{@"cellType":@"group",
                                                        @"label": @"Stories"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Hide stories", @"key":@"hideStories", @"default":@NO
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable reading stories", @"key":@"dontReadStories", @"default":@NO
                                                        }
                                                      ]];
    }
    return _specifiers;
}

@end
