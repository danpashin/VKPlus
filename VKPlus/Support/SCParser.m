//
//  SCParser.m
//  SCParser
//
//  Created by Даниил on 01.05.18.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "SCParser.h"

static NSString * _Nullable const kSCParserCommonErrorDomain = @"ru.danpashin.scparser.common.error";


@interface SCParser ()
@property (strong, nonatomic) dispatch_queue_t parseQueue;
@end


NS_ASSUME_NONNULL_BEGIN

@implementation SCParser

- (instancetype)init 
{
    self = [super init];
    if (self) {
        self.parseQueue = dispatch_queue_create("ru.danpashin.scparser", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)parseAppProvisionWithCompletion:(SCParserCompletion)completion
{
    dispatch_async(self.parseQueue, ^{
        CFURLRef provisionURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("embedded"), CFSTR("mobileprovision"), NULL);
        if (!provisionURL) {
            NSError *error = [self localizedErrorWithCode:4 
                                             description:@"Cannot start parsing. Provision file does not exist."];
            completion(nil, error);
            return;
        }
        CFStringRef provisionPath = CFURLCopyFileSystemPath(provisionURL, kCFURLPOSIXPathStyle);
        CFRelease(provisionURL);
        
        [self parseSignedData:[NSData dataWithContentsOfFile:CFBridgingRelease(provisionPath)] completion:completion];
    });
}

- (void)parseSignedData:(NSData *)signedData completion:(SCParserCompletion)completion
{
    dispatch_async(self.parseQueue, ^{
        CFStringRef signedString = CFStringCreateWithBytes(kCFAllocatorDefault, signedData.bytes, signedData.length, kCFStringEncodingISOLatin1, YES);
        if (!signedString || (CFStringGetLength(signedString) == 0)) {
            if (signedString)
                CFRelease(signedString);
            
            NSError *error = [self localizedErrorWithCode:1 
                                             description:@"Cannot complete parsing. Data is nil or has inappropriate encoding."];
            completion(nil, error);
            return;
        }
        
        CFMutableStringRef mutableDataString = CFStringCreateMutableCopy(kCFAllocatorDefault, signedData.length, signedString);
        CFRelease(signedString);
        
        CFRange beginRange = CFStringFind(mutableDataString, CFSTR("<plist"), kCFCompareCaseInsensitive);
        CFStringDelete(mutableDataString, CFRangeMake(0, beginRange.location-1));
        
        CFRange endRange = CFStringFind(mutableDataString, CFSTR("</plist>"), kCFCompareCaseInsensitive);
        endRange.location = endRange.location + endRange.length;
        endRange.length = CFStringGetLength(mutableDataString) - endRange.location;
        CFStringDelete(mutableDataString, endRange);
        
        CFDataRef unsignedData = CFStringCreateExternalRepresentation(kCFAllocatorDefault, mutableDataString, kCFStringEncodingUTF8, 0);
        CFRelease(mutableDataString);
        
        if (!unsignedData) {
            NSError *error = [self localizedErrorWithCode:2 
                                              description:@"Cannot complete parsing. Parsed data has inappropriate format."];
            completion(nil, error);
            return;
        }
        
        CFErrorRef plistError = NULL;
        NSDictionary *plist =  CFBridgingRelease(CFPropertyListCreateWithData(kCFAllocatorDefault, unsignedData, kCFPropertyListImmutable, NULL, &plistError));
        CFRelease(unsignedData);
        
        if (!plistError && [plist isKindOfClass:[NSDictionary class]]) {
            completion(plist, nil);
        } else {
            NSError *error = [self localizedErrorWithCode:3 
                                             description:@"Cannot complete parsing. Parsed data is not a dictionary."];
            completion(nil, error);
        }
    });
}

- (NSError *)localizedErrorWithCode:(NSInteger)code description:(NSString *)description, ...
{
    va_list args;
    va_start(args, description);
    NSMutableString *localizedDescription = [[NSMutableString alloc] initWithFormat:NSLocalizedString(description, @"") arguments:args];
    va_end(args);
    [localizedDescription appendFormat:NSLocalizedString(@"\n(Error code %i)", @""), (int)code];
    
    return [NSError errorWithDomain:kSCParserCommonErrorDomain code:code 
                        userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}

@end

NS_ASSUME_NONNULL_END
