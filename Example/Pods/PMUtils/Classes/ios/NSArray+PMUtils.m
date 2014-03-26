//
//  NSArray+PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 3/20/14.
//
//

#import "NSArray+PMUtils.h"

@implementation NSArray (PMUtils)

- (NSInteger) shortestCircularDistanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSInteger forwardDistance = [self forwardCircularDistanceFromIndex:fromIndex toIndex:toIndex];
    NSInteger reverseDistance = [self reverseCircularDistanceFromIndex:fromIndex toIndex:toIndex];
    
    if (ABS(reverseDistance) < forwardDistance) {
        return reverseDistance;
    }
    
    return forwardDistance;
}

- (NSInteger) reverseCircularDistanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    return -[self forwardCircularDistanceFromIndex:toIndex toIndex:fromIndex];
}

- (NSInteger) forwardCircularDistanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    NSAssert(fromIndex >= 0 && fromIndex < self.count, @"fromIndex out of bounds");
    NSAssert(toIndex >= 0 && toIndex < self.count, @"toIndex out of bounds");
    
    if (toIndex >= fromIndex) {
        return toIndex - fromIndex;
    }
    else {
        return self.count - fromIndex + toIndex;
    }
    
}

@end
