//
//  PSTableCellHook.m
//  ColoredVK2
//
//  Created by Даниил on 28.06.18.
//

#import <Foundation/Foundation.h>
#import <CaptainHook/CaptainHook.h>

#import "VKParamsPreferences.h"
#import "VKParamsSwitchPrefsCell.h"
#import "SCSegmentPrefsCell.h"
#import "VKParamsButtonCell.h"
#import "VKParamsSelectionCell.h"
#import "VKParamsTextPrefsCell.h"
#import "VKParamsProxyPrefsCell.h"


CHDeclareClass(PSTableCell);
CHDeclareClassMethod(1, Class, PSTableCell, cellClassForSpecifier, PSSpecifier *, specifier)
{
    if ([specifier.target isKindOfClass:[VKParamsPreferences class]]) {
        NSString *cellType = [specifier propertyForKey:@"cellType"];
        
        if ([cellType isEqualToString:@"Switch"]) {
            return [VKParamsSwitchPrefsCell class];
        } else if ([cellType isEqualToString:@"Link"]) {
            specifier.cellType = PSLinkCell;
            if (!specifier.detailControllerClass)
                specifier.detailControllerClass = NSClassFromString([specifier propertyForKey:@"detail"]);
        } else if ([cellType isEqualToString:@"Segment"]) {
            return [SCSegmentPrefsCell class];
        } else if ([cellType isEqualToString:@"Button"]) {
            return [VKParamsButtonCell class];
        } else if ([cellType isEqualToString:@"Select"]) {
            return [VKParamsSelectionCell class];
        } else if ([cellType isEqualToString:@"Text"]) {
            return [VKParamsTextPrefsCell class];
        } else if ([cellType isEqualToString:@"Proxy"]) {
            return [VKParamsProxyPrefsCell class];
        }
        
        if (![specifier propertyForKey:@"cellClass"]) {
            return [SCPreferenceCell class];
        }
    }
    
    return CHSuper(1, PSTableCell, cellClassForSpecifier, specifier);
}
