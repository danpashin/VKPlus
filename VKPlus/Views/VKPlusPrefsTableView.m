//
//  VKPlusPrefsTableView.m
//  VKPlus
//
//  Created by Даниил on 30/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusPrefsTableView.h"

@interface UITableView (Private)
- (UIEdgeInsets)_sectionContentInset;
@end

@implementation VKPlusPrefsTableView

- (UIEdgeInsets)_sectionContentInset
{
    UIEdgeInsets orig = [super _sectionContentInset];
    return UIEdgeInsetsMake(orig.top, 8.0f, orig.bottom, 8.0f);
}

@end
