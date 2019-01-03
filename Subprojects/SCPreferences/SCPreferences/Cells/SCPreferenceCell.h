//
//  SCPreferenceCell.h
//  SCPreferences
//
//  Created by Даниил on 27.06.18.
//

@import Foundation;
@import UIKit;

#import <Preferences/PSSpecifier.h>
@class SCBackgroundView;

@interface SCPreferenceCell : PSTableCell

@property (assign, nonatomic, readonly) SEL defaultPrefsGetter;
@property (weak, nonatomic, readonly) id currentPrefsValue;
@property (strong, nonatomic, readonly) UIViewController *forceTouchPreviewController;
@property (strong, nonatomic, readonly) UIColor *buttonTextColor;



@end
