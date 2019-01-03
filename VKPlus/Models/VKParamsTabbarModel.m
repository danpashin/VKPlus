//
//  VKParamsTabbarModel.m
//  VKParams
//
//  Created by Даниил on 15/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsTabbarModel.h"

@implementation VKParamsTabbarModel

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self sc_decodeObjectsWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self sc_encodeObjectsWithCoder:aCoder];
}

- (instancetype)initWithTitle:(NSString *)title modelSelector:(NSString *)modelSelector
{
    self = [super init];
    if (self) {
        _title = title;
        _modelSelector = modelSelector;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[VKParamsTabbarModel class]])
        return NO;
    
    VKParamsTabbarModel *model = object;
    if (![model.modelSelector isEqualToString:self.modelSelector]
        ) {
        return NO;
    }
    
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> title: '%@', modelSelector: '%@'",
            NSStringFromClass(self.class), self, self.title, self.modelSelector];
}

@end
