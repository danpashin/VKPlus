//
//  SCControlPrefsCell.h
//  SCPreferences
//
//  Created by Даниил on 28.06.18.
//

#import "SCPreferenceCell.h"

@interface SCControlPrefsCell : SCPreferenceCell

- (void)setPreferenceValue:(id)value;
- (void)setPreferenceValue:(id)value forKey:(NSString *)key;

@end
