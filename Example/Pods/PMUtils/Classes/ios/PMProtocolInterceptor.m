//
//  PMProtocolInterceptor.m
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import  <objc/runtime.h>
#import "PMProtocolInterceptor.h"

static inline BOOL selector_belongsToProtocol(SEL selector, Protocol * protocol)
{
    // Reference: https://gist.github.com/numist/3838169
    for (int optionbits = 0; optionbits < (1 << 2); optionbits++) {
        BOOL required = optionbits & 1;
        BOOL instance = !(optionbits & (1 << 1));
        
        struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, selector, required, instance);
        if (hasMethod.name || hasMethod.types) {
            return YES;
        }
    }
    return NO;
}

@implementation PMProtocolInterceptor

- (instancetype)initWithInterceptedProtocol:(Protocol *)interceptedProtocol
{
    self = [super init];
    if (self) {
        _interceptedProtocols = [NSSet setWithObject:interceptedProtocol];
    }
    return self;
}

- (instancetype)initWithInterceptedProtocols:(NSSet *)interceptedProtocols
{
    self = [super init];
    if (self) {
        _interceptedProtocols = [interceptedProtocols copy];
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.middleMan respondsToSelector:aSelector] &&
        [self isSelectorContainedInInterceptedProtocols:aSelector]) {
        return self.middleMan;
    }
    if ([self.receiver respondsToSelector:aSelector]) {
        return self.receiver;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.middleMan respondsToSelector:aSelector] &&
        [self isSelectorContainedInInterceptedProtocols:aSelector]) {
        return YES;
    }
    if ([self.receiver respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (BOOL)isSelectorContainedInInterceptedProtocols:(SEL)aSelector
{
    __block BOOL isSelectorContainedInInterceptedProtocols = NO;
    
    [self.interceptedProtocols enumerateObjectsUsingBlock:^(Protocol * protocol, BOOL *stop) {
        isSelectorContainedInInterceptedProtocols = selector_belongsToProtocol(aSelector, protocol);
        *stop = isSelectorContainedInInterceptedProtocols;
    }];
    return isSelectorContainedInInterceptedProtocols;
}


@end
