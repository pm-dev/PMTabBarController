//
//  UIView+PMUtils.m
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import "UIView+PMUtils.h"
#import "UIImage+PMUtils.h"

@implementation UIView (PMUtils)

+ (NSString *) nibName
{
	return NSStringFromClass([self class]);
}

+ (UINib *) nib
{
	return [UINib nibWithNibName:[self nibName] bundle:nil];
}

- (void) removeSubviews
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

- (UIImage *)blurredViewWithRadius:(CGFloat)radius
						 iterations:(NSUInteger)iterations
					scaleDownFactor:(NSUInteger)scaleDownFactor
						 saturation:(CGFloat)saturation
						  tintColor:(UIColor *)tintColor
							   crop:(CGRect)crop
{
	UIGraphicsBeginImageContextWithOptions(crop.size, YES, 1.0f);

	[self drawViewHierarchyInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) afterScreenUpdates:NO];
	
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return 	[snapshot blurredImageWithRadius:radius
								  iterations:iterations
							 scaleDownFactor:scaleDownFactor
								  saturation:saturation
								   tintColor:tintColor
										crop:crop];
}

@end
