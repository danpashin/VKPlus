//
//  VKParamsProxyEditController.m
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsProxyEditController.h"
#import "VKParamsSelectionCell.h"
#import "VKParamsTextPrefsCell.h"
#import "VKParamsNavigationController.h"

@interface VKParamsProxyEditController () <VKParamsTextPrefsCellDelegate>
@property (strong, nonatomic) VKParamsProxyModel *proxyModel;

@end

@implementation VKParamsProxyEditController

- (instancetype)initWithProxyModel:(VKParamsProxyModel *)proxyModel
{
    self = [super init];
    if (self) {
        self.proxyModel = proxyModel;
    }
    return self;
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray <PSSpecifier *> *mutableSpecifiers = [NSMutableArray array];
        
        NSArray <NSDictionary *> *dictSpecifiers = @[
                                                     @{@"cellType":@"group", @"label":@"Type"},
                                                     @{@"cellType":@"Select", @"label":@"HTTPS",
                                                       @"key":[self.proxyModel proxyIDForType:VKParamsProxyTypeHTTPS] },
//                                                     @{@"cellType":@"Select", @"label":@"SOCKS5", 
//                                                       @"key":[self.proxyModel proxyIDForType:VKParamsProxyTypeSOCKS5] },
                                                     @{@"cellType":@"group", @"label":@"Connection"},
                                                     @{@"cellType":@"Text", @"label":@"Server",
                                                       @"key":@"serverAddress",
                                                       @"text":self.proxyModel.host
                                                       },
                                                     @{@"cellType":@"Text", @"label":@"Port",
                                                       @"key":@"serverPort",
                                                       @"text": self.proxyModel.port
                                                       },
                                                     @{@"cellType":@"group", @"label":@"Authorization_optional"},
                                                     @{@"cellType":@"Text", @"label":@"Login",
                                                       @"key":@"serverLogin",
                                                       @"text":self.proxyModel.login
                                                       },
                                                     @{@"cellType":@"Text", @"label":@"Password",
                                                       @"key":@"serverPass",
                                                       @"text":self.proxyModel.password
                                                       }
                                                     ];
        [mutableSpecifiers addObjectsFromArray:[self parseSpecifiersForArray:dictSpecifiers]];
        
        _specifiers = mutableSpecifiers;
    }
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    if ([specifier.identifier isEqualToString:[self.proxyModel proxyIDForType:self.proxyModel.type]])
        return @YES;
    
    return nil;
}

- (void)presentFrom:(UIViewController *)controller
{
    VKParamsNavigationController *navigation = [[VKParamsNavigationController alloc] initWithRootViewController:self];
    navigation.modalPresentationStyle = UIModalPresentationPageSheet;
    [controller presentViewController:navigation animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = VKPLocalized(@"Change proxy");
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self action:@selector(dismiss)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                           target:self action:@selector(actionSave)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)dismiss
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSave
{
    [self.delegate proxyEditController:self didEndEditingModel:self.proxyModel];
    [self dismiss];
}


#pragma mark -
#pragma mark VKParamsTextPrefsCellDelegate
#pragma mark -

- (void)textCellRequestedConfiguration:(VKParamsTextPrefsCell *)textCell
{
    textCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if ([textCell.specifier.identifier isEqualToString:@"serverPort"]) {
        textCell.textField.keyboardType = UIKeyboardTypeNumberPad;
    } else if ([textCell.specifier.identifier isEqualToString:@"serverLogin"]) {
        if (@available(iOS 11_0, *)) {
            textCell.textField.textContentType = UITextContentTypeUsername;
        }
    }  else if ([textCell.specifier.identifier isEqualToString:@"serverPass"]) {
        textCell.textField.secureTextEntry = YES;
        if (@available(iOS 11_0, *)) {
            textCell.textField.textContentType = UITextContentTypePassword;
        }
    }
}

- (BOOL)textCell:(VKParamsTextPrefsCell *)textCell canUpdateText:(NSString *)oldText withText:(NSString *)newText
{
    if ([textCell.specifier.identifier isEqualToString:@"serverAddress"]) {
        self.proxyModel.host = newText;
    } else if ([textCell.specifier.identifier isEqualToString:@"serverPort"]) {
        self.proxyModel.port = newText;
    } else if ([textCell.specifier.identifier isEqualToString:@"serverLogin"]) {
        self.proxyModel.login = newText;
    } else if ([textCell.specifier.identifier isEqualToString:@"serverPass"]) {
        self.proxyModel.password = newText;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = (self.proxyModel.host.length > 0 &&
                                                      self.proxyModel.port.integerValue > 0);
    
    return YES;
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    VKParamsSelectionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.specifier.identifier containsString:@"proxyType"] && [cell isKindOfClass:[VKParamsSelectionCell class]]) {
        VKParamsSelectionCell *selectedCell = [self cachedCellForSpecifierID:self.proxyModel.identifier];
        selectedCell.tickView.enabled = NO;
        
        self.proxyModel.type = [self.proxyModel proxyTypeForID:cell.specifier.identifier];
        [cell.tickView setEnabled:YES animated:YES];
    }
}

@end
