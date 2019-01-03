//
//  VKParamsTextPrefsCell.m
//  VKParams
//
//  Created by Даниил on 22/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTextPrefsCell.h"

@interface VKParamsTextPrefsCell () <UITextFieldDelegate>
@property (strong, nonatomic) NSLayoutConstraint *textFieldLeading;
@end

@implementation VKParamsTextPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        _textField = [[UITextField alloc] init];
        self.textField.delegate = self;
        self.textField.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.textField];
        
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textField.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0f].active = YES;
        [self.textField.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0f].active = YES;
        self.textFieldLeading = [self.textField.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor];
        self.textFieldLeading.active = YES;
        [self.textField.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-2.5f * self.layoutMargins.right].active = YES;
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    self.textField.text = [specifier propertyForKey:@"text"];
    self.textField.placeholder = [specifier propertyForKey:@"placeholder"];
    
    if (self.textField.text.length == 0) {
        id specifierValue = self.specifier.performGetter;
        self.textField.text = [specifierValue isKindOfClass:[NSString class]] ? specifierValue : nil;
    }
    
    CGSize textSize = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:self.textLabel.font}];
    self.textFieldLeading.constant = textSize.width + self.layoutMargins.left + 16.0f;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow && [self.cellTarget respondsToSelector:@selector(textCellRequestedConfiguration:)])
        [self.cellTarget textCellRequestedConfiguration:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
        [self.textField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self.cellTarget respondsToSelector:@selector(textCell:canUpdateText:withText:)])
        return [self.cellTarget textCell:self canUpdateText:textField.text withText:newText];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.cellTarget respondsToSelector:@selector(textCellWillBeginEditing:)])
        [self.cellTarget textCellWillBeginEditing:self];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.cellTarget respondsToSelector:@selector(textCellDidEndEditing:)])
        [self.cellTarget textCellDidEndEditing:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = YES;
    if ([self.cellTarget respondsToSelector:@selector(textCellShouldReturn:)])
        shouldReturn = [self.cellTarget textCellShouldReturn:self];
    
    if (shouldReturn && textField.returnKeyType == UIReturnKeyDone)
        [self endEditing:YES];
    
    return shouldReturn;
}

@end
