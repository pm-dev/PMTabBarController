//
//  NSArray+PMUtils.h
//  Pods
//
//  Created by Peter Meyers on 3/20/14.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (PMUtils)

- (NSInteger) distanceFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex circular:(BOOL)circular;

@end
