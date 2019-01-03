//
//  UITableViewCell+VKPlus.m
//  VKPlus
//
//  Created by Даниил on 30/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "UITableViewCell+VKPlus.h"
#import <objc/runtime.h>

@implementation UITableViewCell (VKPlus)

+ (UITableViewCell *)vkp_prefsMainCell
{
    Class cellClass = objc_lookUpClass("VKMCell") ?: [self class];
    
    UITableViewCell *cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"vkpSettingsCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"VK++";
    cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    
    return cell;
}

@end
