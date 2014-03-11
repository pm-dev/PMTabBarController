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

- (UIImage *)applyBlurWithCrop:(CGRect)bounds
						resize:(CGSize)size
					blurRadius:(CGFloat)blurRadius
					 tintColor:(UIColor *)tintColor
		 saturationDeltaFactor:(CGFloat)saturationDeltaFactor
					 maskImage:(UIImage *) maskImage;

@end
