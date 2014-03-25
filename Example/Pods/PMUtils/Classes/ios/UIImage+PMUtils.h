//
//  UIImage+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (PMUtils)

- (UIImage *) makeResizableHorizontally:(BOOL)horizontal vertically:(BOOL)vertical;

- (UIImage *) drawnImage;

+ (UIImage *) cachedImageWithFile:(NSString *)path;

+ (UIImage *) cachedImageWithData:(NSData *)data;

- (UIImage *)blurredImageWithRadius:(CGFloat)radius
						 iterations:(NSUInteger)iterations
					scaleDownFactor:(NSUInteger)scaleDownFactor
						 saturation:(CGFloat)saturation
						  tintColor:(UIColor *)tintColor
							   crop:(CGRect)crop;
@end
