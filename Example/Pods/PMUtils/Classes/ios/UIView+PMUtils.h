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

- (UIImage *)blurredViewWithRadius:(CGFloat)radius
						iterations:(NSUInteger)iterations
				   scaleDownFactor:(NSUInteger)scaleDownFactor
						saturation:(CGFloat)saturation
						 tintColor:(UIColor *)tintColor
							  crop:(CGRect)crop;
@end
