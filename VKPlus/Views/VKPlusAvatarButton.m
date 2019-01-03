//
//  VKPlusAvatarButton.m
//  VKPlus
//
//  Created by Даниил on 06/09/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKPlusAvatarButton.h"
#import "VKPlusUserModel.h"
#import <objc/runtime.h>

@interface VKPlusAvatarButton ()
@property (strong, nonatomic) VKPlusUserModel *model;
@end

@implementation VKPlusAvatarButton

+ (instancetype)buttonWithFrame:(CGRect)frame userID:(NSNumber *)userID
{
    return [[self alloc] initWithFrame:frame userID:userID];
}

- (instancetype)initWithFrame:(CGRect)frame userID:(NSNumber *)userID
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:[UIImage imageNamed:@"placeholder_user_36"] animated:NO];
        self.model = [VKPlusUserModel modelForUserID:userID];
        [self updateAvatar];
        
        __weak typeof(self) weakSelf = self;
        [self.model updateWithCompletion:^{
            [weakSelf updateAvatar];
        }];
    }
    return self;
}

- (void)updateAvatar
{
    [self.model loadAvatarWithSize:self.frame.size completion:^(UIImage * _Nullable avatar) {
        if (avatar) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:avatar animated:YES];
            });
        }
    }];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    if (animated) {
        [UIView transitionWithView:self duration:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self setImage:image forState:UIControlStateNormal];
        } completion:nil];
    } else {
        [self setImage:image forState:UIControlStateNormal];
    }
}

@end
