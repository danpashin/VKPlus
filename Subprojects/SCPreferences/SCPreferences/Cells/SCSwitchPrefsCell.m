//
//  SCSwitchPrefsCell.m
//  SCPreferences
//
//  Created by Даниил on 27.06.18.
//

#import "SCSwitchPrefsCell.h"

@interface SCSwitchPrefsCell ()
@property (assign, nonatomic) BOOL switchPrefsLoaded;
@end

@implementation SCSwitchPrefsCell

+ (Class)switchClass
{
    return [UISwitch class];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.switchView = [self.class.switchClass new];
        [self.switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.switchView;
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    if (!self.switchPrefsLoaded || [specifier propertyForKey:@"wasReloaded"]) {
        [specifier removePropertyForKey:@"wasReloaded"];
        self.switchPrefsLoaded = YES;
        [self updateSwitchWithSpecifier:specifier];
    }
}

#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)switchTriggered:(__kindof UISwitch *)switchView
{
    [self setPreferenceValue:@(switchView.on)];
}

- (void)updateSwitchWithSpecifier:(PSSpecifier *)specifier
{
    NSNumber *currentValue = self.currentPrefsValue;
    if ([currentValue isKindOfClass:[NSNumber class]]) {
        self.switchView.on = currentValue.boolValue;
    }
}

@end
