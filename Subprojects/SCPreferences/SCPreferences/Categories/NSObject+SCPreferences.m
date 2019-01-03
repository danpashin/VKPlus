//
//  NSObject+SCPreferences.m
//  SCPreferences
//
//  Created by Даниил on 10/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "NSObject+SCPreferences.h"
#import <objc/runtime.h>

@implementation NSObject (SCPreferences)

+ (void)sc_runAsyncBlockOnMainThread:(void(^)(void))block
{
    if (!block)
        return; 
    
    if ([NSThread isMainThread])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

- (nullable void *)sc_executeSelector:(SEL)selector
{
    return [self sc_executeSelector:selector arguments:nil];
}

- (nullable void *)sc_executeSelector:(SEL)selector arguments:(nullable id)firstArgument, ...
{
    if (![self respondsToSelector:selector])
        return nil;
    
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;
    
    if (firstArgument) {
        [invocation setArgument:&firstArgument atIndex:2];
        va_list args;
        va_start(args, firstArgument);
        
        NSInteger argumentIndex = 3;
        id argument = nil;
        while ((argument = va_arg(args,id))) {
            [invocation setArgument:&argument atIndex:argumentIndex];
            argumentIndex++;
        }
        va_end(args);
    }
    [invocation invoke];
    
    void *result = NULL;
    if (strcmp(signature.methodReturnType, "v") != 0)
        [invocation getReturnValue:&result];
    
    return result;
}

+ (NSDictionary<NSString *, Class> *)sc_codableProperties
{
    unsigned int propertyCount;
    __autoreleasing NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
            //get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        __autoreleasing NSString *key = @(propertyName);
        
            //get property type
        Class propertyClass = nil;
        char *typeEncoding = property_copyAttributeValue(property, "T");
        switch (typeEncoding[0]) {
            case '@': {
                if (strlen(typeEncoding) >= 3) {
                    char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                    __autoreleasing NSString *name = @(className);
                    NSRange range = [name rangeOfString:@"<"];
                    if (range.location != NSNotFound) {
                        name = [name substringToIndex:range.location];
                    }
                    propertyClass = NSClassFromString(name) ?: [NSObject class];
                    free(className);
                }
                break;
            }
            case 'c':
            case 'i':
            case 's':
            case 'l':
            case 'q':
            case 'C':
            case 'I':
            case 'S':
            case 'L':
            case 'Q':
            case 'f':
            case 'd':
            case 'B': {
                propertyClass = [NSNumber class];
                break;
            }
            case '{': {
                propertyClass = [NSValue class];
                break;
            }
        }
        free(typeEncoding);
        
        if (propertyClass) {
                //check if there is a backing ivar
            char *ivar = property_copyAttributeValue(property, "V");
            if (ivar) {
                    //check if ivar has KVC-compliant name
                __autoreleasing NSString *ivarName = @(ivar);
                if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[@"_" stringByAppendingString:key]]) {
                        //no setter, but setValue:forKey: will still work
                    codableProperties[key] = propertyClass;
                }
                free(ivar);
            } else {
                    //check if property is dynamic and readwrite
                char *dynamic = property_copyAttributeValue(property, "D");
                char *readonly = property_copyAttributeValue(property, "R");
                if (dynamic && !readonly) {
                        //no ivar, but setValue:forKey: will still work
                    codableProperties[key] = propertyClass;
                }
                free(dynamic);
                free(readonly);
            }
        }
    }
    
    free(properties);
    return codableProperties;
}

- (NSDictionary<NSString *, Class> *)sc_codableProperties
{
    NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
    Class subclass = [self class];
    while (subclass != [NSObject class]) {
        [(NSMutableDictionary *)codableProperties addEntriesFromDictionary:[subclass sc_codableProperties]];
        subclass = [subclass superclass];
    }
    
    return codableProperties;
}

- (void)sc_decodeObjectsWithCoder:(NSCoder *)aDecoder
{
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = [[self class] supportsSecureCoding];
    NSDictionary *properties = self.sc_codableProperties;
    for (NSString *key in properties) {
        id object = nil;
        Class propertyClass = properties[key];
        if (secureAvailable) {
            object = [aDecoder decodeObjectOfClass:propertyClass forKey:key];
        }
        else {
            object = [aDecoder decodeObjectForKey:key];
        }
        if (object) {
            if (secureSupported && ![object isKindOfClass:propertyClass] && object != [NSNull null])
                return;
            
            [self setValue:object forKey:key];
        }
    }
}

- (void)sc_encodeObjectsWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in self.sc_codableProperties) {
        id object = [self valueForKey:key];
        if (object) [aCoder encodeObject:object forKey:key];
    }
}

@end
