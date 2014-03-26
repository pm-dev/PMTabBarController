//
//  NSArray+PMUtils.h
//  Pods
//
//  Created by Peter Meyers on 3/20/14.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (PMUtils)

- (NSInteger) shortestCircularDistanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (NSInteger) reverseCircularDistanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (NSInteger) forwardCircularDistanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
