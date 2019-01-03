//
//  VKPlusMusicPrefs.m
//  VKPlus
//
//  Created by Даниил on 03/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusMusicPrefs.h"

@interface VKPlusMusicPrefs ()

@end

@implementation VKPlusMusicPrefs

- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = [self parseSpecifiersForArray:@[
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Bypass_music_block_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Bypass music block", @"key":@"bypassMusicBlock", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Disable_30_minute_limit_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable 30 minute limit", @"key":@"disableMusicLimit", @"default":@NO
                                                        }
                                                      ]];
    }
    return _specifiers;
}

@end

