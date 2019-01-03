//
//  VKParamsHostPinger.m
//  VKParams
//
//  Created by Даниил on 24/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "VKParamsHostPinger.h"

@interface VKParamsHostPinger ()

@property (strong, nonatomic) NSTimer *pingTimer;
@property (strong, nonatomic) NSDate *pingStartDate;
@property (assign, nonatomic) BOOL hostResponded;

@end

@implementation VKParamsHostPinger

+ (VKParamsHostPinger *)pingerWithHost:(NSString *)host
{
    VKParamsHostPinger *pinger = [[VKParamsHostPinger alloc] initWithHostName:host];
    pinger.packetsCount = 5;
    pinger.delegate = pinger;
    return pinger;
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [self.pingTimer invalidate];
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
}

- (void)sendPing
{
    [self sendPingWithData:nil];
}

- (void)stop
{
    [self.pingTimer invalidate];
    [super stop];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    self.pingStartDate = [NSDate date];
    
    if (!self.hostResponded && self.failureHandler)
        self.failureHandler(self, nil);
    
    if (sequenceNumber >= self.packetsCount - 1)
        [self stop];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval dateInterval = currentDate.timeIntervalSince1970 - self.pingStartDate.timeIntervalSince1970;
    float hostLatency = roundf((float)dateInterval * 1000.0f);
    
    if (self.successHandler)
        self.successHandler(self, packet.length, hostLatency);
    
    self.hostResponded = YES;
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    self.hostResponded = NO;
    
    if (self.failureHandler)
        self.failureHandler(self, error);
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    if (self.failureHandler)
        self.failureHandler(self, error);
}

@end
