//
//  NSArray+PMUtils.m
//  Pods
//
//  Created by Peter Meyers on 3/20/14.
//
//

#import "NSArray+PMUtils.h"

@implementation NSArray (PMUtils)

- (NSInteger) distanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex circular:(BOOL)circular;
{
    NSAssert(fromIndex >= 0 && fromIndex < self.count, @"fromIndex out of bounds");
    NSAssert(toIndex >= 0 && toIndex < self.count, @"toIndex out of bounds");
    
    NSInteger distance = toIndex - fromIndex;
    
    if (circular) {
    
        NSInteger count = (distance < 0)? self.count : -self.count;
        NSInteger wrappedDistance = count + distance;
        
        if (ABS(wrappedDistance) < ABS(distance)) {
            return wrappedDistance;
        }
    }
    return distance;
}

@end
