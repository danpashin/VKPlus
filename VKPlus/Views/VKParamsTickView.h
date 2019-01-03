//
//  VKParamsTickView.h
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsTickView : UIView

@property (assign, nonatomic) BOOL enabled;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
