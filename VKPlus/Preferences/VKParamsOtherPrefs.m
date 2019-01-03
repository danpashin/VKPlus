//
//  VKParamsOtherPrefs.m
//  VKParams
//
//  Created by Даниил on 14/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsOtherPrefs.h"

@interface VKParamsOtherPrefs ()

@end

@implementation VKParamsOtherPrefs
- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = [self parseSpecifiersForArray:@[
                                                      @{@"cellType":@"group"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable safe links", @"key":@"disableSafeBrowsing", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group", @"label": @"Profile",
                                                        @"footerText": @"Disable_age_restriction_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable age restriction", @"key":@"disableAdultRestriction", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group", 
                                                        @"footerText": @"Bypass_blacklist_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Bypass blacklist", @"key":@"bypassBlacklist", @"default":@NO
                                                        }
                                                      ]];
    }
    return _specifiers;
}

@end
