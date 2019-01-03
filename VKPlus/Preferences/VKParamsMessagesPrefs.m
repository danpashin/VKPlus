//
//  VKParamsMessagesPrefs.m
//  VKParams
//
//  Created by Даниил on 14/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsMessagesPrefs.h"
#import "VKParamsTextPrefsCell.h"

@interface VKParamsMessagesPrefs () <VKParamsTextPrefsCellDelegate>

@end

#ifndef COMPILE_APP
extern long long cachedUnreadMessagesCount;
#else
long long cachedUnreadMessagesCount = 0;
#endif

@implementation VKParamsMessagesPrefs

- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = [self parseSpecifiersForArray:@[
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Hide_typing_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Disable reading messages", @"key":@"dontReadMessages", @"default":@NO
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Hide typing", @"key":@"hideMessageTyping", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group",
                                                        @"footerText": @"Hide_call_button_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"Hide call button", @"key":@"hideCallButton", @"default":@NO
                                                        },
                                                      @{@"cellType":@"group"
                                                        },
                                                      @{@"cellType":@"group", @"label":@"badge",
                                                        @"footerText": @"messages_badge_footer"
                                                        },
                                                      @{@"cellType":@"Switch", @"label":@"hide_messages_badge", @"key":@"hideMessagesBadge", @"default":@NO
                                                        },
                                                      @{@"cellType":@"Text", @"label":@"messages_badge_custom_text", @"key":@"messageBadgeCustomText", 
                                                        @"placeholder": [NSString stringWithFormat:@"%lld", cachedUnreadMessagesCount]
                                                        }
                                                      ]];
    }
    return _specifiers;
}

- (BOOL)textCellShouldReturn:(VKParamsTextPrefsCell *)textCell
{
    [self setPreferenceValue:textCell.textField.text specifier:textCell.specifier];
    
    return YES;
}

- (void)textCellRequestedConfiguration:(VKParamsTextPrefsCell *)textCell
{
    textCell.textField.returnKeyType = UIReturnKeyDone;
}

@end
