//
//  UIScrollView+PMUtils.h
//  Pods
//
//  Created by Peter Meyers on 3/25/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PMScrollDirection) {
    PMScrollDirectionNone,
    PMScrollDirectionPositive,
    PMScrollDirectionNegative
};

@interface UIScrollView (PMUtils)

- (void) killScroll;

@end
