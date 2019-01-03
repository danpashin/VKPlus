//
//  SCSwitchPrefsCell.h
//  SCPreferences
//
//  Created by Даниил on 27.06.18.
//

#import "SCControlPrefsCell.h"

@interface SCSwitchPrefsCell : SCControlPrefsCell

@property (nonatomic, readonly, class) Class switchClass;
@property (nonatomic, strong) __kindof UISwitch *switchView;

- (void)switchTriggered:(__kindof UISwitch *)switchView;
- (void)updateSwitchWithSpecifier:(PSSpecifier *)specifier NS_REQUIRES_SUPER;

@end
