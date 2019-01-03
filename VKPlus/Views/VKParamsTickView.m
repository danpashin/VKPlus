//
//  VKParamsTickView.m
//  VKParams
//
//  Created by Даниил on 21/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTickView.h"
#import "VKParamsImages.h"

@interface VKParamsTickView ()
@property(nonatomic, readonly, strong) CAGradientLayer *layer;
@property(nonatomic, strong) CAShapeLayer *tickLayer;

@end

@implementation VKParamsTickView
@dynamic layer;

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 20.0f)];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 20.0f)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat maxSide = MAX(frame.size.width, frame.size.height);
    frame.size = CGSizeMake(maxSide, maxSide / 2.0f);
    
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.colors = @[(id)VKParamsImages.secondaryColor.CGColor, (id)VKParamsImages.mainColor.CGColor];
        self.layer.locations = @[@0.0, @1.0];
        self.layer.startPoint = CGPointMake(0, 1);
        self.layer.startPoint = CGPointMake(1, 0);
        
        self.tickLayer = [CAShapeLayer layer];
        self.tickLayer.frame = frame;
        self.tickLayer.strokeColor = VKParamsImages.secondaryColor.CGColor;
        self.tickLayer.fillColor = [UIColor clearColor].CGColor;
        self.tickLayer.strokeEnd = 0.0f;
        self.tickLayer.lineWidth = 2.0f;
        self.tickLayer.lineCap = kCALineCapRound;
        self.layer.mask = self.tickLayer;
        
        CGMutablePathRef mutableTickPath = CGPathCreateMutable();
        CGPathMoveToPoint(mutableTickPath, NULL, CGRectGetMaxX(self.frame) / 4.0f, CGRectGetMidY(self.frame));
        CGPathAddLineToPoint(mutableTickPath, NULL, CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 1.0f);
        CGPathAddLineToPoint(mutableTickPath, NULL, CGRectGetMaxX(self.frame) - CGRectGetMidX(self.frame) / 4.0f, CGRectGetMinY(self.frame) + 1.0f);
        self.tickLayer.path = mutableTickPath;
        CGPathRelease(mutableTickPath);
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    [self setEnabled:enabled animated:NO];
}

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated
{
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.fromValue = @(self.enabled);
        pathAnimation.toValue = @(enabled);
        pathAnimation.duration = 0.2f;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.tickLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
        self.tickLayer.strokeEnd = (CGFloat)enabled;
    } else {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        self.tickLayer.strokeEnd = (CGFloat)enabled;
        [CATransaction commit];
    }
    
    _enabled = enabled;
}

@end
