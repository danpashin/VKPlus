//
//  VKParamsPreferences.h
//  VKParams
//
//  Created by Даниил on 10/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <SCPreferenceController.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsPreferences : SCPreferenceController

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSMutableDictionary *cachedPrefs NS_UNAVAILABLE;

- (NSMutableArray <PSSpecifier *> *)parseSpecifiersForArray:(NSArray <NSDictionary *> *)specifiersArray;
- (PSSpecifier *)linkSpecifierWithName:(NSString *)name detailClass:(nullable Class)detailClass;

@end

NS_ASSUME_NONNULL_END
