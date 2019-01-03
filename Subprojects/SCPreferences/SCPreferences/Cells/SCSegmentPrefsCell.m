//
//  SCSegmentPrefsCell.m
//  SCPreferences
//
//  Created by Даниил on 27.06.18.
//

#import "SCSegmentPrefsCell.h"
#import "NSObject+SCPreferences.h"

@interface SCSegmentPrefsCell ()
@property (strong, nonatomic) UISegmentedControl *segment;
@end

@implementation SCSegmentPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        CGFloat segmentHeight = 34.0f;
        
        self.segment = [UISegmentedControl new];
        self.segment.layer.cornerRadius = segmentHeight / 2;
        self.segment.layer.borderWidth = 1.0f;
        self.segment.layer.masksToBounds = YES;
        [self.segment addTarget:self action:@selector(segmentTriggered:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.segment];
        
        self.segment.translatesAutoresizingMaskIntoConstraints = NO;
        [self.segment.heightAnchor constraintEqualToConstant:segmentHeight].active = YES;
        [self.segment.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[segment]-8-|" options:0 
                                                                                 metrics:nil views:@{@"segment":self.segment}]];
    }
    return self;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    self.segment.tintColor = self.tintColor;
    self.segment.layer.borderColor = self.tintColor.CGColor;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    if (self.segment.numberOfSegments == 0) {
        NSArray <NSString *> *titles = [specifier propertyForKey:@"validTitles"];
        for (NSString *title in titles) {
            NSString *localized = [self localizedValueForKey:title];
            [self.segment insertSegmentWithTitle:localized atIndex:self.segment.numberOfSegments animated:NO];
        }
        
        id currentValue = self.currentPrefsValue;
        if (currentValue) {
            NSArray *values = [specifier propertyForKey:@"validValues"];
            self.segment.selectedSegmentIndex = [values indexOfObject:currentValue];
        }
    }
}

- (NSString *)localizedValueForKey:(NSString *)key
{
    return [self.cellTarget sc_executeSelector:@selector(localizedValueForKey:) arguments:key, nil];
}

- (void)segmentTriggered:(UISegmentedControl *)segment
{
    NSArray *values = [self.specifier propertyForKey:@"validValues"];
    id selectedValue = values[self.segment.selectedSegmentIndex];
    [self setPreferenceValue:selectedValue];
}

- (id)customBackgroundView
{
    return nil;
}

@end
