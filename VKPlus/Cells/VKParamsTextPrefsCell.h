//
//  VKParamsTextPrefsCell.h
//  VKParams
//
//  Created by Даниил on 22/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <SCPreferenceCell.h>

NS_ASSUME_NONNULL_BEGIN

@class VKParamsTextPrefsCell;
@protocol VKParamsTextPrefsCellDelegate <NSObject>

@optional
- (BOOL)textCell:(VKParamsTextPrefsCell *)textCell canUpdateText:(NSString *)oldText withText:(NSString *)newText;

- (void)textCellRequestedConfiguration:(VKParamsTextPrefsCell *)textCell;

- (void)textCellWillBeginEditing:(VKParamsTextPrefsCell *)textCell;
- (void)textCellDidEndEditing:(VKParamsTextPrefsCell *)textCell;

- (BOOL)textCellShouldReturn:(VKParamsTextPrefsCell *)textCell;

@end

@interface VKParamsTextPrefsCell : SCPreferenceCell

@property (strong, nonatomic, readonly) UITextField *textField;

@end

NS_ASSUME_NONNULL_END
