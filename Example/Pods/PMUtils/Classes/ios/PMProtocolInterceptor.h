//
//  PMProtocolInterceptor.h
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import <Foundation/Foundation.h>

@interface PMProtocolInterceptor : NSObject

@property (nonatomic, readonly, copy) NSSet * interceptedProtocols;
@property (nonatomic, weak) id receiver;
@property (nonatomic, weak) id middleMan;

- (instancetype)initWithInterceptedProtocol:(Protocol *)interceptedProtocol;
- (instancetype)initWithInterceptedProtocols:(NSSet *)interceptedProtocols;

@end
