//
//  SCControlPrefsCell.m
//  SCPreferences
//
//  Created by Даниил on 28.06.18.
//

#import "SCControlPrefsCell.h"
#import "NSObject+SCPreferences.h"

@implementation SCControlPrefsCell

- (void)setPreferenceValue:(id)value
{
    [self.cellTarget sc_executeSelector:@selector(setPreferenceValue:specifier:) arguments:value, self.specifier, nil];
}

- (void)setPreferenceValue:(id)value forKey:(NSString *)key
{
    [self.cellTarget sc_executeSelector:@selector(setPreferenceValue:forKey:) arguments:value, key, nil];
}

@end
