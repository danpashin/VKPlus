//
//  VKParamsProxyPrefsCell.m
//  VKParams
//
//  Created by Даниил on 22/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsProxyPrefsCell.h"
#import "VKParamsProxyModel.h"
#import "VKParamsImages.h"
#import "VKParamsHostPinger.h"

@interface VKParamsProxyPrefsCell () <NSURLSessionTaskDelegate, SimplePingDelegate>
@property (strong, nonatomic) VKParamsProxyModel *proxyModel;
@property (strong, nonatomic) VKParamsHostPinger *pinger;
@end


@implementation VKParamsProxyPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier];
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    self.proxyModel = [specifier propertyForKey:@"proxyModel"];
    [self.pinger stop];
    
    if (self.proxyModel) {
        NSString *label = [NSString stringWithFormat:@"%@:%@", self.proxyModel.host, self.proxyModel.port];
        NSMutableAttributedString *attributedLabel = [[NSMutableAttributedString alloc] initWithString:label];
        
        NSRange colonRange = [label rangeOfString:@":"];
        [attributedLabel addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] 
                                range:NSMakeRange(colonRange.location, label.length - colonRange.location)];
        self.titleLabel.attributedText = attributedLabel;
        
        self.detailTextLabel.text = self.proxyModel.protocol;
        
        self.pinger = [VKParamsHostPinger pingerWithHost:self.proxyModel.host];
        
        __weak typeof(self) weakSelf = self;
        self.pinger.successHandler = ^(VKParamsHostPinger * _Nonnull pinger, NSUInteger packetSize, float latency) {
            [pinger stop];
            [weakSelf setDetailSuccessText:[NSString stringWithFormat:VKPLocalized(@"%@, ping %.0f ms"), weakSelf.proxyModel.protocol, latency]];
        };
        
        self.pinger.failureHandler = ^(VKParamsHostPinger * _Nonnull pinger, NSError * _Nonnull hostError) {
            NSString *errorText = [NSString stringWithFormat:VKPLocalized(@"%@, ping unknown"), weakSelf.proxyModel.protocol];
            NSMutableAttributedString *attributedError = [[NSMutableAttributedString alloc] initWithString:errorText];
            [attributedError addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, errorText.length)];
            
            NSRange commaRange = [errorText rangeOfString:@", "];
            if (commaRange.location != NSNotFound) {
                [attributedError addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] 
                                        range:NSMakeRange(commaRange.location + 2, errorText.length - commaRange.location - 2)];
            }
            [weakSelf setDetailAttributedText:attributedError];
        };
        [self.pinger start];
    }
}

- (void)setDetailAttributedText:(NSAttributedString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.15f;
        [self.detailTextLabel.layer addAnimation:animation forKey:@"fadeAnimation"];
        
        self.detailTextLabel.text = text.string;
        self.detailTextLabel.attributedText = text;
    });
}

- (void)setDetailSuccessText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.15f;
        [self.detailTextLabel.layer addAnimation:animation forKey:@"fadeAnimation"];
        
        self.detailTextLabel.text = text;
        self.detailTextLabel.textColor = VKParamsImages.mainColor;
    });
}

@end
