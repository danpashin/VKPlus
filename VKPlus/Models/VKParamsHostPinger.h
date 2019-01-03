//
//  VKParamsHostPinger.h
//  VKParams
//
//  Created by Даниил on 24/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "SimplePing.h"

NS_ASSUME_NONNULL_BEGIN

@interface VKParamsHostPinger : SimplePing <SimplePingDelegate>

+ (VKParamsHostPinger *)pingerWithHost:(NSString *)host;

/**
 По умолчанию 5
 */
@property (assign, nonatomic) uint16_t packetsCount;

@property (copy, nonatomic) void (^successHandler)(VKParamsHostPinger *pinger, NSUInteger packetSize, float latency);
@property (copy, nonatomic) void (^failureHandler)(VKParamsHostPinger *pinger, NSError * _Nullable hostError);

@end

NS_ASSUME_NONNULL_END
