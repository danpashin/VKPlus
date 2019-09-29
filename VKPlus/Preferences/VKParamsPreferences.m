//
//  VKParamsPreferences.m
//  VKParams
//
//  Created by Даниил on 10/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsPreferences.h"
#import "VKPlusPrefsTableView.h"
#import <objc/runtime.h>

extern void reloadPrefs(BOOL async);
#ifdef COMPILE_APP
void reloadPrefs(BOOL async) {};
#endif

@interface VKParamsPreferences () {
    UINavigationItem *_navigationItem;
}

@end


@implementation VKParamsPreferences
@dynamic cachedPrefs;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (Class)tableViewClass
{
    return [VKPlusPrefsTableView class];
}

- (void)commonInit
{
#ifdef COMPILE_APP
    self.userDefaults = [NSUserDefaults standardUserDefaults];
#else
    self.userDefaults = [NSUserDefaults vkp_standartDefaults];
#endif
    [super commonInit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.specifier.name;
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

- (nullable id)readPreferenceValue:(PSSpecifier *)specifier
{
    if (!specifier.properties[@"key"])
        return nil;
    
    id savedValue = [self.userDefaults objectForKey:specifier.properties[@"key"]];
    if (!savedValue)
        return specifier.properties[@"default"];
    
    return savedValue;
}

- (void)setPreferenceValue:(nullable id)value forKey:(NSString *)key
{
    [self.userDefaults setObject:value forKey:key];
    [super setPreferenceValue:value forKey:key];
}

- (void)writePrefs:(NSDictionary *)prefs
{
    reloadPrefs(YES);
}


- (UINavigationItem *)navigationItem
{
    Class VANavigationItemClass = objc_lookUpClass("VANavigationItem");
    if (VANavigationItemClass && !_navigationItem) {
        _navigationItem = [[VANavigationItemClass alloc] init];
    }
    
    if (!_navigationItem) {
        _navigationItem = super.navigationItem;
    }
    
    return _navigationItem;
}


- (PSSpecifier *)linkSpecifierWithName:(NSString *)name detailClass:(Class)detailClass
{
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:VKPLocalized(name) target:self set:nil get:nil detail:detailClass cell:PSLinkCell edit:nil];
    [specifier setProperty:@YES forKey:@"enabled"];
    return specifier;
}

- (NSMutableArray <PSSpecifier *> *)parseSpecifiersForArray:(NSArray <NSDictionary *> *)specifiersArray
{
    NSMutableArray <PSSpecifier *> *specifiers = [NSMutableArray array];
    
    for (NSDictionary *item in specifiersArray) {
        PSSpecifier *specifier = nil;
        NSString *name = item[@"label"];
        if (name) {
            name = VKPLocalized(item[@"label"]);
        }
        
        if ([item[@"cellType"] isEqualToString:@"group"]) {
            specifier = [PSSpecifier groupSpecifierWithName:name];
        } else {
            specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:@selector(setPreferenceValue:specifier:) 
                                                          get:@selector(readPreferenceValue:) detail:item[@"detail"] cell:PSStaticTextCell edit:nil];
        }
        
        if (specifier) {
            specifier.identifier = [item[@"key"] copy];
            [specifier.properties addEntriesFromDictionary:item];
            [specifiers addObject:specifier];
        }
    }
    
    return specifiers;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerText = [super tableView:tableView titleForFooterInSection:section];
    if (footerText) {
        footerText = VKPLocalized(footerText);
    }
    
    return footerText;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        headerView.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] + 2.0f weight:UIFontWeightBlack];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
        footerView.textLabel.textColor = [UIColor darkGrayColor];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = -1.0f;
    if (section != 0) {
        PSSpecifier *previousGroupSpecifier = [self specifierAtIndex:[self indexOfGroup:section - 1]];
        NSString *footerText = [previousGroupSpecifier propertyForKey:PSFooterTextGroupKey];
        
        PSSpecifier *specifier = [self specifierAtIndex:[self indexOfGroup:section]];
        NSString *label = [specifier propertyForKey:PSTitleKey];
        
        if (label.length > 0 && footerText.length > 0)
            height = 56.0f;
    }
    
    return height;
}

@end
