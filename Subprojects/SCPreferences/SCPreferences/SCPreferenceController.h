//
//  SCPreferenceController.h
//  SCPreferences
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>


NS_ASSUME_NONNULL_BEGIN

@interface SCPreferenceController : PSListController

@property (strong, nonatomic) NSMutableDictionary *cachedPrefs;

@property (strong, nonatomic, readonly) NSDictionary *defaultPreferences;
@property (strong, nonatomic, readonly) NSBundle *defaultBundle;


- (void)commonInit NS_REQUIRES_SUPER;

- (void)openURL:(NSString *)url;
- (void)presentPopover:(UIViewController *)controller;
- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize;

- (nullable id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(nullable id)value specifier:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(nullable id)value forKey:(NSString *)key;
- (void)updateSpecifierWithKey:(NSString *)key;

- (void)writePrefsWithCompetion:(nullable void(^)(void))completionBlock NS_REQUIRES_SUPER;
- (void)readPrefsWithCompetion:(nullable void(^)(void))completionBlock NS_REQUIRES_SUPER;


- (void)completeReadingPrefs;
- (void)writePrefs:(NSDictionary *)prefs;
- (void)didWritePrefs;


@end

NS_ASSUME_NONNULL_END
