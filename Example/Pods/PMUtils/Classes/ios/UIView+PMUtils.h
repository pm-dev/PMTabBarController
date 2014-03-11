//
//  UIView+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <UIKit/UIKit.h>

@interface UIView (PMUtils)

+ (NSString *) nibName;

+ (UINib *) nib;

- (UIImage *) blurredViewWithCrop:(CGRect)bounds
						   resize:(CGSize)size
					   blurRadius:(CGFloat)blurRadius
						tintColor:(UIColor *)tintColor
			saturationDeltaFactor:(CGFloat)saturationDeltaFactor
						maskImage:(UIImage *)maskImage;

@end
