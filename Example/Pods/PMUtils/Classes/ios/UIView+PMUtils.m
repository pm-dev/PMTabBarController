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

- (UIImage *) blurredViewWithCrop:(CGRect)bounds
						   resize:(CGSize)size
					   blurRadius:(CGFloat)blurRadius
						tintColor:(UIColor *)tintColor
			saturationDeltaFactor:(CGFloat)saturationDeltaFactor
						maskImage:(UIImage *)maskImage
{
	UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1.0f);
	
	[self drawViewHierarchyInRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height) afterScreenUpdates:NO];
	
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return [snapshot applyBlurWithCrop:bounds
								resize:size
							blurRadius:blurRadius
							 tintColor:tintColor
				 saturationDeltaFactor:saturationDeltaFactor
							 maskImage:maskImage];
}

@end
