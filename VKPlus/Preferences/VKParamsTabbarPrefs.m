//
//  VKParamsTabbarPrefs.m
//  VKParams
//
//  Created by Даниил on 16/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTabbarPrefs.h"
#import "VKParamsTabbarModel.h"
#import <SCPreferenceCell.h>
#import "VKParamsTickView.h"

@interface VKParamsTabbarPrefs ()

@property (strong, nonatomic) NSMutableArray <VKParamsTabbarModel *> *enabledModels;
@property (strong, nonatomic) NSMutableArray <VKParamsTabbarModel *> *disabledModels;

@property (weak, nonatomic) PSSpecifier *enabledGroupSpecifier;
@property (weak, nonatomic) PSSpecifier *disabledGroupSpecifier;

@property (assign, nonatomic) NSUInteger selectedTabbarIndex;

@end


extern BOOL shouldUpdateTabbar;
#ifdef COMPILE_APP
BOOL shouldUpdateTabbar;
#endif

@implementation VKParamsTabbarPrefs

- (NSArray *)specifiers
{
    if (!_specifiers || _specifiers.count == 0) {
        NSMutableArray <PSSpecifier *> *mutableSpecifiers = [NSMutableArray array];
        
        PSSpecifier *enabledGroupSpecifier = [PSSpecifier groupSpecifierWithName:VKPLocalized(@"Displayed tabs")];
        [enabledGroupSpecifier setProperty:VKPLocalized(@"Displayed_tabs_footer") forKey:@"footerText"];
        self.enabledGroupSpecifier = enabledGroupSpecifier;
        [mutableSpecifiers addObject:enabledGroupSpecifier];
        for (VKParamsTabbarModel *model in self.enabledModels) {
            [mutableSpecifiers addObject:[self specifierForModel:model]];
        }
        
        PSSpecifier *disabledGroupSpecifier = [PSSpecifier groupSpecifierWithName:VKPLocalized(@"Hidden")];
        self.disabledGroupSpecifier = disabledGroupSpecifier;
        [mutableSpecifiers addObject:disabledGroupSpecifier];
        for (VKParamsTabbarModel *model in self.disabledModels) {
            [mutableSpecifiers addObject:[self specifierForModel:model]];
        }
        
        _specifiers = mutableSpecifiers;
    }
    return _specifiers;
}

- (PSSpecifier *)specifierForModel:(VKParamsTabbarModel *)model
{
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:model.title target:self 
                                                               set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) 
                                                            detail:nil cell:PSStaticTextCell edit:nil];
    [specifier setProperty:model forKey:@"model"];
    
    NSBundle *iconBundle = model.iconFromVKApp ? [NSBundle mainBundle] : [NSBundle vkp_defaultBundle];
    UIImage *iconImage = [UIImage imageNamed:model.imageName inBundle:iconBundle compatibleWithTraitCollection:nil];
    iconImage = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [specifier setProperty:iconImage forKey:@"iconImage"];
    
    return specifier;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    return [specifier propertyForKey:@"model"] ? nil : [super readPreferenceValue:specifier];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    if (![specifier propertyForKey:@"model"])
        [super setPreferenceValue:value specifier:specifier];
}

- (void)commonInit
{
    [super commonInit];
    [self updateItemsIgnoreSaved:NO];
}

- (void)updateItemsIgnoreSaved:(BOOL)ignoreSaved
{
    self.enabledModels = [NSMutableArray array];
    self.disabledModels = [NSMutableArray array];
    
    NSDictionary <NSNumber *, VKParamsTabbarModel *> *enabledModelsDict = nil;
    id savedValue = [self.userDefaults objectForKey:@"tabbarItems"];
    if (!ignoreSaved && [savedValue isKindOfClass:[NSData class]]) {
        self.selectedTabbarIndex = (NSUInteger)[self.userDefaults integerForKey:@"selectedTabbarIndex"];
        enabledModelsDict = [NSKeyedUnarchiver unarchiveObjectWithData:savedValue];
    } else {
        self.selectedTabbarIndex = 0;
        enabledModelsDict = VKParamsTabbarModel.defaultModels;
    }
    
    for (NSNumber *enabledModelsIndex in [enabledModelsDict.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        VKParamsTabbarModel *tabbarModel = enabledModelsDict[enabledModelsIndex];
        [self.enabledModels insertObject:tabbarModel atIndex:enabledModelsIndex.unsignedIntegerValue];
    }
    
    NSDictionary *allModels = VKParamsTabbarModel.allModels;
    for (NSNumber *modelIndex in [allModels.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        VKParamsTabbarModel *model = allModels[modelIndex];
        if (![self.enabledModels containsObject:model]) {
            [self.disabledModels addObject:model];
        }
    }
}

- (void)setSelectedTabbarIndex:(NSUInteger)selectedTabbarIndex
{
    _selectedTabbarIndex = selectedTabbarIndex;
    
    [_specifiers enumerateObjectsUsingBlock:^(PSSpecifier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PSTableCell *cell = [self cachedCellForSpecifier:obj];
        if ([cell.editingAccessoryView isKindOfClass:[VKParamsTickView class]]) {
            ((VKParamsTickView *)cell.editingAccessoryView).enabled = NO;
        }
    }];
    
    if (_specifiers.count > 0) {
        PSSpecifier *specifier = [self specifierAtIndexPath:[NSIndexPath indexPathForRow:selectedTabbarIndex inSection:0]];
        PSTableCell *cell = [self cachedCellForSpecifier:specifier];
        if ([cell.editingAccessoryView isKindOfClass:[VKParamsTickView class]]) {
            [((VKParamsTickView *)cell.editingAccessoryView) setEnabled:YES animated:YES];
        }
    }
}

- (void)loadView
{
    [super loadView];
    
    self.table.editing = YES;
    self.table.allowsSelectionDuringEditing = YES;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:VKPLocalized(@"Reset") style:UIBarButtonItemStylePlain 
                                                                            target:self action:@selector(resetItems)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                           target:self action:@selector(dismiss)];
}

- (void)dismiss
{
    [self.delegate controllerRequestedDismissing:self];
}

- (void)resetItems
{
    [self setPreferenceValue:@0 forKey:@"selectedTabbarIndex"];
    
    [self updateItemsIgnoreSaved:YES];
    [self reloadSpecifiers];
    [self saveSettings];
}

- (void)saveSettings
{
    self.selectedTabbarIndex = self.selectedTabbarIndex;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSUInteger index = 0;
        NSMutableDictionary <NSNumber *, VKParamsTabbarModel *> *enabledModelsDict = [NSMutableDictionary dictionary];
        for (VKParamsTabbarModel *model in self.enabledModels) {
            enabledModelsDict[@(index)] = model;
            index++;
            if (index > 4)
                break;
        }
        NSData *enabledModelsData = [NSKeyedArchiver archivedDataWithRootObject:enabledModelsDict];
        
        shouldUpdateTabbar = YES;
        [self setPreferenceValue:enabledModelsData forKey:@"tabbarItems"];
    });
}

- (void)moveSpecifierAtIndexPath:(NSIndexPath *)sourceIndexPath toGroup:(NSInteger)groupIndex
{
    @synchronized (self) {
        NSUInteger numberOfEnabledItems = self.enabledModels.count;
        if (sourceIndexPath.section == 0 && groupIndex == 1 && numberOfEnabledItems <= 1)
            return;
        
        if (sourceIndexPath.section == 1 && groupIndex == 0 && numberOfEnabledItems >= 5)
            return;
        
        PSSpecifier *specifier = [self specifierAtIndexPath:sourceIndexPath];
        
        NSIndexPath *newIndexPath = nil;
        if (groupIndex == 0) {
            [self removeSpecifier:specifier animated:YES];
            [self insertSpecifier:specifier atEndOfGroup:groupIndex animated:YES];
            newIndexPath = [NSIndexPath indexPathForRow:numberOfEnabledItems inSection:groupIndex];
        } else {
            [self removeSpecifier:specifier animated:NO];
            [self insertSpecifier:specifier afterSpecifier:self.disabledGroupSpecifier animated:YES];
            newIndexPath = [NSIndexPath indexPathForRow:0 inSection:groupIndex];
        }
        
        [self tableView:self.table moveRowAtIndexPath:sourceIndexPath toIndexPath:newIndexPath];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource
#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.imageView.tintColor = [UIColor colorWithRed:149/255.0f green:160/255.0f blue:173/255.0f alpha:1.0f];
    cell.indentationLevel = -35;
    
    VKParamsTickView *tickView = [[VKParamsTickView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    cell.editingAccessoryView = tickView;
    
    if (indexPath.section == 0 && indexPath.row == self.selectedTabbarIndex) {
        tickView.enabled = YES;
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        VKParamsTabbarModel *model = self.enabledModels[indexPath.row];
        return [model.modelSelector isEqualToString:@"menu"] ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleInsert;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSUInteger countOfEnabledModels = self.enabledModels.count;
    if (sourceIndexPath.section == 1 && proposedDestinationIndexPath.section == 0 && countOfEnabledModels >= 5) {
        return sourceIndexPath;
    } else if (sourceIndexPath.section == 0 && proposedDestinationIndexPath.section == 1) {
        VKParamsTabbarModel *model = self.enabledModels[sourceIndexPath.row];
        if ([model.modelSelector isEqualToString:@"menu"] || countOfEnabledModels <= 1) {
            return sourceIndexPath;
        }
    }
    
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return @[[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:VKPLocalized(@"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull actionIndexPath) {
            [self moveSpecifierAtIndexPath:actionIndexPath toGroup:1];
        }]];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    BOOL wasChanged = ((sourceIndexPath.section != destinationIndexPath.section) || (sourceIndexPath.row != destinationIndexPath.row));
    if (wasChanged && !(sourceIndexPath.section == 1 && destinationIndexPath.section == 1)) {
        if (sourceIndexPath.section == 0) {
            VKParamsTabbarModel *model = self.enabledModels[sourceIndexPath.row];
            [self.enabledModels removeObject:model];
            if (destinationIndexPath.section == 0) {
                [self.enabledModels insertObject:model atIndex:destinationIndexPath.row];
            } else if (destinationIndexPath.section == 1) {
                [self.disabledModels insertObject:model atIndex:destinationIndexPath.row];
            }
        } else if (sourceIndexPath.section == 1 && destinationIndexPath.section == 0) {
            VKParamsTabbarModel *model = self.disabledModels[sourceIndexPath.row];
            [self.disabledModels removeObject:model];
            [self.enabledModels insertObject:model atIndex:destinationIndexPath.row];
        } else if (sourceIndexPath.section == 1 && destinationIndexPath.section == 1) {
            VKParamsTabbarModel *model = self.disabledModels[sourceIndexPath.row];
            [self.disabledModels removeObject:model];
            [self.disabledModels insertObject:model atIndex:destinationIndexPath.row];
        }
        
        [self saveSettings];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadSpecifiers];
        tableView.editing = NO;
        tableView.editing = YES;
    });
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.enabledModels.count < 5 && editingStyle == UITableViewCellEditingStyleInsert) {
        [self moveSpecifierAtIndexPath:indexPath toGroup:0];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != 0)
        return;
    
    self.selectedTabbarIndex = indexPath.row;
    [self setPreferenceValue:@(indexPath.row) forKey:@"selectedTabbarIndex"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return 48.0f;
    
    return -1.0f;
}

@end
