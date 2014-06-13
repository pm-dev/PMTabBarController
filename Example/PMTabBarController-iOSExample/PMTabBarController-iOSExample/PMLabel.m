//
//  PMLabel.m
//  PMTabBarController-iOSExample
//
//  Created by Peter Meyers on 6/12/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMLabel.h"

@implementation PMLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
