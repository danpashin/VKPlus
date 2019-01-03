//
//  SCPreferenceController.m
//  SCPreferences
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

#import "SCPreferenceController.h"
#import "SCPreferenceCell.h"

#import <SafariServices/SFSafariViewController.h>
#import "NSObject+SCPreferences.h"

static NSString *const kPackageNotificationReloadInternalPrefs = @"ru.danpashin.scpreferences.reload";

@interface SCPreferenceController (Private)  <UIViewControllerPreviewingDelegate>
@end

@implementation SCPreferenceController
@synthesize defaultPreferences = _defaultPreferences;
@synthesize defaultBundle = _defaultBundle;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPrefsNotification) name:kPackageNotificationReloadInternalPrefs object:nil];
    
    [self readPrefsWithCompetion:^{
        [self completeReadingPrefs];
    }];
}



- (void)loadView
{
    [super loadView];
    
    self.table.separatorColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.specifier ? self.specifier.name : @"";
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)presentPopover:(UIViewController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
        controller.modalPresentationStyle = UIModalPresentationPopover;
        controller.popoverPresentationController.permittedArrowDirections = 0;
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = self.view.bounds;
        [self presentViewController:controller animated:YES completion:nil];
    });
}

- (void)openURL:(NSString *)url
{
    SFSafariViewController *safariController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
    safariController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:safariController animated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Specifiers
#pragma mark -

- (NSArray *)specifiers
{
    if (!_specifiers) {
        _specifiers = @[];
    }
    return _specifiers;
}

- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize 
{
    NSMutableArray <PSSpecifier *> *specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:self.defaultBundle] mutableCopy];
    
    @autoreleasepool {
        if (specifiersArray.count > 0 && localize) {
            for (PSSpecifier *specifier in specifiersArray) {
                [self localizeSpecifier:specifier];
            }
        }
    }
    
    if (specifiersArray.count == 0)
        specifiersArray = [NSMutableArray array];
    
    return specifiersArray;
}

- (void)localizeSpecifier:(PSSpecifier *)specifier
{
    specifier.name = [self localizedValueForKey:specifier.name];
    
    NSString *footerDictText = specifier.properties[@"footerText"];
    if (footerDictText) {
        [specifier setProperty:[self localizedValueForKey:footerDictText] forKey:@"footerText"];
    }
    
    if (specifier.properties[@"label"])
        [specifier setProperty:[self localizedValueForKey:specifier.properties[@"label"]] forKey:@"label"];
    if (specifier.properties[@"detailedLabel"])
        [specifier setProperty:[self localizedValueForKey:specifier.properties[@"detailedLabel"]] forKey:@"detailedLabel"];
}

- (NSString *)localizedValueForKey:(NSString *)key
{
    return key;
}

- (NSBundle *)defaultBundle
{
    if (!_defaultBundle) {
        _defaultBundle = [NSBundle mainBundle];
    }
    
    return _defaultBundle;
}

#pragma mark -
#pragma mark Cells
#pragma mark -

- (BOOL)edgeToEdgeCells
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.userInteractionEnabled = YES;
    
//    CGFloat edgeOffset = IS_IPAD ? 36.0f : 18.0f;
//    cell.layoutMargins = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 18.0f);
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.preservesSuperviewLayoutMargins = NO;
    cell.separatorInset = UIEdgeInsetsZero;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}

#pragma mark -
#pragma mark UIViewControllerPreviewingDelegate
#pragma mark -

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    SCPreferenceCell *prefsCell = (SCPreferenceCell *)previewingContext.sourceView;
    if ([prefsCell isKindOfClass:[SCPreferenceCell class]]) {
        previewingContext.sourceRect = [self.view convertRect:prefsCell.frame fromView:self.table];
        return prefsCell.forceTouchPreviewController;
    }
    
    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    viewControllerToCommit.view.backgroundColor = [UIColor whiteColor];
    [self showViewController:viewControllerToCommit sender:nil];
}


#pragma mark -
#pragma mark Preferences
#pragma mark -

- (void)readPrefsWithCompetion:(nullable void(^)(void))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.cachedPrefs = [self.defaultPreferences mutableCopy];
        
        if (completionBlock)
            completionBlock();
    });
}

- (NSDictionary *)defaultPreferences
{
    if (!_defaultPreferences) {
        _defaultPreferences = @{};
    }
    
    return _defaultPreferences;
}


- (void)completeReadingPrefs
{
    
}

- (nullable id)readPreferenceValue:(PSSpecifier *)specifier
{
    if (!specifier.properties[@"key"])
        return nil;
    
    if (!self.cachedPrefs[specifier.properties[@"key"]])
        return specifier.properties[@"default"];
    
    return self.cachedPrefs[specifier.properties[@"key"]];
}


- (void)writePrefsWithCompetion:(nullable void(^)(void))completionBlock
{
    @synchronized(self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self writePrefs:[self.cachedPrefs copy]];
            
            if (completionBlock)
                completionBlock();
        });
    }
}

- (void)writePrefs:(NSDictionary *)prefs
{
    
}

- (void)didWritePrefs
{
    
}

- (void)setPreferenceValue:(nullable id)value specifier:(PSSpecifier *)specifier
{
    [self setPreferenceValue:value forKey:specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(nullable id)value forKey:(NSString *)key
{
    @synchronized(self) {
        if (!key || key.length == 0)
            return;
        
        if (value)
            self.cachedPrefs[key] = value;
        else
            [self.cachedPrefs removeObjectForKey:key];
        
        [self writePrefsWithCompetion:^{
            [self updateSpecifierWithKey:key];
            [self didWritePrefs];
        }];
    }
}



- (void)reloadSpecifiers
{
    [NSObject sc_runAsyncBlockOnMainThread:^{
        [super reloadSpecifiers];
    }];
}

- (void)updateSpecifierWithKey:(NSString *)key
{
    PSSpecifier *specifier = [self specifierForID:key];
    if (!specifier)
        return;
    
    [specifier setProperty:@YES forKey:@"wasReloaded"];
    
    PSTableCell *cachedCell = specifier ? [self cachedCellForSpecifier:specifier] : nil;
    if (cachedCell) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cachedCell refreshCellContentsWithSpecifier:specifier];
        });
    }
}

- (void)reloadPrefsNotification
{
    [self readPrefsWithCompetion:nil];
}


@end
