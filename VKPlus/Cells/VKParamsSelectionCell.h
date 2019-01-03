//
//  VKParamsSelectionCell.h
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <SCPreferenceCell.h>
#import "VKParamsTickView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsSelectionCell : SCPreferenceCell
@property (nonatomic, strong, readonly) VKParamsTickView *tickView;
@end

NS_ASSUME_NONNULL_END
