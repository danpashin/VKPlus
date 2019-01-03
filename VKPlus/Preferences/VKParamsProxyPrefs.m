//
//  VKParamsProxyPrefs.m
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsProxyPrefs.h"
#import "VKParamsProxyEditController.h"
#import "VKParamsImages.h"

#import "VKParamsProxyPrefsCell.h"
#import "VKParamsTextPrefsCell.h"
#import "VKParamsSwitchPrefsCell.h"

#import <SCPreferenceCell.h>


@interface VKParamsProxyPrefs () <VKParamsProxyEditControllerDelegate>
@property (strong, nonatomic, readonly) NSMutableArray <VKParamsProxyModel *> *savedProxies;
@property (weak, nonatomic) PSSpecifier *selectedProxySpecifier;
@property (strong, nonatomic) VKParamsProxyModel *selectedProxyModel;
@end

@implementation VKParamsProxyPrefs

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSArray <NSDictionary *> *dictSpecifiers = @[
                                                     @{@"cellType":@"Text", @"label":@"OAuth domain", 
                                                       @"key":@"oauthDomain", @"placeholder":@"api.vk.com"
                                                       },
                                                     @{@"cellType":@"Text", @"label":@"API domain", 
                                                       @"key":@"apiDomain", @"placeholder":@"api.vk.com"
                                                       },
                                                     @{@"cellType":@"group"
                                                       },
                                                     @{@"cellType":@"Switch", @"label":@"Disable SSL certificate check", 
                                                       @"key":@"disableCertificateCheck", @"default":@NO
                                                       },
                                                     @{@"cellType":@"group", @"footerText":@"Use_proxy_footer"
                                                       },
                                                     @{@"cellType":@"Switch", @"label":@"Use proxy",
                                                       @"key":@"useProxy", @"default":@NO
                                                       },
                                                     @{@"cellType":@"group", @"label":@"Saved proxy"
                                                       },
                                                     @{@"cellType":@"Button", @"label":@"Add", 
                                                       @"key":@"addProxy", @"iconImage":VKParamsImages.addIcon, 
                                                       @"action":NSStringFromSelector(@selector(actionAddProxy))
                                                       }
                                                     ];
        NSMutableArray <PSSpecifier *> *mutableSpecifiers = [self parseSpecifiersForArray:dictSpecifiers];
        
        [self.savedProxies enumerateObjectsUsingBlock:^(VKParamsProxyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PSSpecifier *specifier = [self createSpecifierForProxyModel:obj];
            if (specifier)
                [mutableSpecifiers addObject:specifier];
            
            if ([self.selectedProxyModel isEqual:obj]) {
                self.selectedProxySpecifier = specifier;
            }
        }];
        
        _specifiers = mutableSpecifiers;
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value forKey:(NSString *)key
{
    [super setPreferenceValue:value forKey:key];
    
    if ([key isEqualToString:@"useProxy"]) {
        VKParamsSwitchPrefsCell *certCell = [self cachedCellForSpecifierID:@"disableCertificateCheck"];
        if ([certCell isKindOfClass:[VKParamsSwitchPrefsCell class]]) {
            NSNumber *savedValue = [self readPreferenceValue:[self specifierForID:@"disableCertificateCheck"]];
            [certCell.switchView setOn:((NSNumber *)savedValue).boolValue animated:YES];
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    if ([specifier.identifier isEqualToString:@"disableCertificateCheck"]) {
        PSSpecifier *useProxySpecifier = [self specifierForID:@"useProxy"];
        NSNumber *useProxy = [super readPreferenceValue:useProxySpecifier];
        if (useProxy.boolValue) {
            return @YES;
        }
    } else if ([self.selectedProxySpecifier isEqual:specifier])
        return @YES;
    
    return [super readPreferenceValue:specifier];
}

- (void)commonInit
{
    _savedProxies = [NSMutableArray array];
    [super commonInit];
}

- (void)completeReadingPrefs
{
    NSData *selectedProxy = [self.userDefaults objectForKey:@"selectedProxy"];
    if ([selectedProxy isKindOfClass:[NSData class]]) {
        self.selectedProxyModel = [NSKeyedUnarchiver unarchiveObjectWithData:selectedProxy];
    }
    
    NSData *savedProxiesData = [self.userDefaults objectForKey:@"proxies"];
    if ([savedProxiesData isKindOfClass:[NSData class]]) {
        NSArray *savedProxies = [NSKeyedUnarchiver unarchiveObjectWithData:savedProxiesData];
        if ([savedProxies isKindOfClass:[NSArray class]]) {
            [self.savedProxies removeAllObjects];
            [self.savedProxies addObjectsFromArray:savedProxies];
            [self reloadSpecifiers];
        }
    }
}


#pragma mark -
#pragma mark Specifier creation

- (void)addProxyModelToTable:(VKParamsProxyModel *)proxyModel
{
    PSSpecifier *specifier = [self createSpecifierForProxyModel:proxyModel];
    if (specifier) {
        [self insertSpecifier:specifier afterSpecifierID:@"addProxy"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadSpecifiers];
        });
    }
}

- (PSSpecifier *)createSpecifierForProxyModel:(VKParamsProxyModel *)proxyModel
{
    if (![proxyModel isKindOfClass:[VKParamsProxyModel class]])
        return nil;
    
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:@selector(setPreferenceValue:specifier:) 
                                                               get:@selector(readPreferenceValue:) detail:nil cell:PSStaticTextCell edit:nil];
    [specifier setProperty:@"Proxy" forKey:@"cellType"];
    [specifier setProperty:proxyModel forKey:@"proxyModel"];
    
    return specifier;
}

- (void)savePreferences
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *selectedProxyData = nil;
        if (self.selectedProxyModel) {
            selectedProxyData = [NSKeyedArchiver archivedDataWithRootObject:self.selectedProxyModel];
        }
        [self setPreferenceValue:selectedProxyData forKey:@"selectedProxy"];
        
        NSData *savedProxiesData = [NSKeyedArchiver archivedDataWithRootObject:self.savedProxies];
        [self setPreferenceValue:savedProxiesData forKey:@"proxies"];
    });
}

- (void)actionAddProxy
{
    VKParamsProxyModel *newModel = [VKParamsProxyModel new];
    VKParamsProxyEditController *controller = [[VKParamsProxyEditController alloc] initWithProxyModel:newModel];
    controller.delegate = self;
    [controller presentFrom:self];
}


#pragma mark -
#pragma mark VKParamsProxyEditControllerDelegate

- (void)proxyEditController:(VKParamsProxyEditController *)proxyEditController didEndEditingModel:(VKParamsProxyModel *)proxyModel
{
    if (![self.savedProxies containsObject:proxyModel]) {
        [self.savedProxies insertObject:proxyModel atIndex:0];
        [self addProxyModelToTable:proxyModel];
    } else {
        [self reloadSpecifier:proxyEditController.specifier animated:YES];
    }
    [self savePreferences];
}


#pragma mark -
#pragma mark VKParamsTextPrefsCellDelegate
- (void)textCellRequestedConfiguration:(VKParamsTextPrefsCell *)textCell
{
    textCell.textField.keyboardType = UIKeyboardTypeURL;
    textCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (@available(iOS 10.0, *)) {
        textCell.textField.textContentType = UITextContentTypeURL;
    }
    
    if ([textCell.specifier.identifier isEqualToString:@"oauthDomain"]) {
        textCell.textField.returnKeyType = UIReturnKeyNext;
    } else if ([textCell.specifier.identifier isEqualToString:@"apiDomain"]) {
        textCell.textField.returnKeyType = UIReturnKeyDone;
    }
}

- (void)textCellDidEndEditing:(VKParamsTextPrefsCell *)textCell
{
    NSString *text = (textCell.textField.text.length > 0) ? textCell.textField.text : nil;
    [self setPreferenceValue:text forKey:textCell.specifier.identifier];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[VKParamsProxyPrefsCell class]]) {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
        cell.tintColor = VKParamsImages.mainColor;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    if ([specifier propertyForKey:@"proxyModel"])
        return YES;
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
        [self removeSpecifier:specifier];
        [self.savedProxies removeObject:[specifier propertyForKey:@"proxyModel"]];
        if ([specifier isEqual:self.selectedProxySpecifier]) {
            self.selectedProxyModel = nil;
        }
        
        [self savePreferences];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    if ([[specifier propertyForKey:@"cellType"] isEqualToString:@"Proxy"]) {
        return height * 1.15f;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    if ([[specifier propertyForKey:@"cellType"] isEqual:@"Proxy"]) {
        VKParamsProxyPrefsCell *selectedProxyCell = [self cachedCellForSpecifier:self.selectedProxySpecifier];
        selectedProxyCell.tickView.enabled = NO;
        
        
        VKParamsProxyPrefsCell *proxyCell = [self cachedCellForSpecifier:specifier];
        [proxyCell.tickView setEnabled:YES animated:YES];
        self.selectedProxySpecifier = specifier;
        self.selectedProxyModel = [specifier propertyForKey:@"proxyModel"];
        [self savePreferences];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    VKParamsProxyModel *proxyModel = [specifier propertyForKey:@"proxyModel"];
    if (proxyModel) {
        VKParamsProxyEditController *controller = [[VKParamsProxyEditController alloc] initWithProxyModel:proxyModel];
        controller.specifier = specifier;
        controller.delegate = self;
        [controller presentFrom:self];
    }
}

@end
