//
//  VKParamsMainPreferences.m
//  VKParams
//
//  Created by Даниил on 13/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsMainPreferences.h"
#import "VKParamsFeedPrefs.h"
#import "VKPlusMusicPrefs.h"
#import "VKParamsMessagesPrefs.h"
#import "VKParamsOtherPrefs.h"
#import "VKParamsTabbarPrefsContext.h"
#import "VKParamsProxyPrefs.h"

@interface VKParamsMainPreferences ()

@end

@implementation VKParamsMainPreferences

#ifndef COMPILE_APP
extern NSString *applicationBuildNumber;
#else
NSString *applicationBuildNumber = @"0";
#endif

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray <PSSpecifier *> *mutableSpecifiers = [NSMutableArray array];
        
        
        PSSpecifier *newsSpecifier = [self linkSpecifierWithName:@"News" detailClass:[VKParamsFeedPrefs class]];
        [newsSpecifier setProperty:[UIImage vkp_iconNamed:@"settings/post"] forKey:@"iconImage"];
        [mutableSpecifiers addObject:newsSpecifier];
        
        PSSpecifier *messagesSpecifier = [self linkSpecifierWithName:@"Messages" detailClass:[VKParamsMessagesPrefs class]];
        [messagesSpecifier setProperty:[UIImage imageNamed:@"tabbar/messages"] forKey:@"iconImage"];
        [mutableSpecifiers addObject:messagesSpecifier];
        
        PSSpecifier *tabbarSpecifier = [self linkSpecifierWithName:@"Tab bar" detailClass:nil];
        [tabbarSpecifier setProperty:[UIImage vkp_iconNamed:@"settings/tabbar"] forKey:@"iconImage"];
        tabbarSpecifier.identifier = @"tabbarLink";
        [mutableSpecifiers addObject:tabbarSpecifier];
        
        
        PSSpecifier *musicLinkSpecifier = [self linkSpecifierWithName:@"Music" detailClass:[VKPlusMusicPrefs class]];
        [musicLinkSpecifier setProperty:[UIImage vkp_iconNamed:@"tabbar/music_normal_24"] forKey:@"iconImage"];
        [mutableSpecifiers addObjectsFromArray:@[[PSSpecifier emptyGroupSpecifier], musicLinkSpecifier]];

        PSSpecifier *networkSpecifier = [self linkSpecifierWithName:@"Network and proxy" detailClass:VKParamsProxyPrefs.class];
        [networkSpecifier setProperty:[UIImage vkp_iconNamed:@"settings/proxy"] forKey:@"iconImage"];
        [mutableSpecifiers addObject:networkSpecifier];
        
        PSSpecifier *otherSpecifier = [self linkSpecifierWithName:@"Miscellaneous" detailClass:[VKParamsOtherPrefs class]];
        [otherSpecifier setProperty:[UIImage vkp_iconNamed:@"settings/more"] forKey:@"iconImage"];
        [mutableSpecifiers addObject:otherSpecifier];
        
        PSSpecifier *footer = [PSSpecifier emptyGroupSpecifier];
        [footer setProperty:self.footerText forKey:@"footerText"];
        [footer setProperty:@"1" forKey:@"footerAlignment"];
        [mutableSpecifiers addObject:footer];
        
        _specifiers = mutableSpecifiers;
    }
    return _specifiers;
}

- (NSString *)footerText
{
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    NSString *app_version = (__bridge NSString *)CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("CFBundleShortVersionString"));
    NSString *ios_version = [UIDevice currentDevice].systemVersion;
    
    NSString *footerText = [NSString stringWithFormat:VKPLocalized(@"iOS version: %@\nTweak version: %@\nVK App version: %@ (%@)"),
            ios_version, productBundleVersion, app_version, applicationBuildNumber];
    footerText = [footerText stringByAppendingString:@"\n\n© Daniil Pashin 2018"];
    return footerText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"VK++";
}

- (void)presentTabbarController
{
    VKParamsTabbarPrefsContext *container = [VKParamsTabbarPrefsContext new];
    container.rootPreferenceController = self;
    [container presentController];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    if ([specifier.identifier isEqualToString:@"tabbarLink"]) {
        [self presentTabbarController];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
