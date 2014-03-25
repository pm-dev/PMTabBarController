//
//  UIImage+PMUtils.m
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import "UIImage+PMUtils.h"
#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>

static NSUInteger const bitsPerComponent = 8;
static NSUInteger const bytesPerPixel = 4;

@implementation UIImage (PMUtils)

- (UIImage *) makeResizableHorizontally:(BOOL)horizontal vertically:(BOOL)vertical;
{
	// return a resizable image with one pixel of flex horizonally
	// and vertically all the rest in the end caps
	// the images should be an odd number of pixels for non-retina
	// but this will still work on images with even number of pixels but
	// the end caps will be one pixel smaller on right and bottom
	
	float endCapLeft = floorf((self.size.width - 1.0) / 2.0);
	float endCapTop = floorf((self.size.height - 1.0) / 2.0);
	
	UIEdgeInsets capInsets = UIEdgeInsetsMake(vertical? endCapTop : 0.0,
											  horizontal? endCapLeft : 0.0,
											  vertical? floorf(self.size.height - endCapTop - 1.0) : 0.0,
											  horizontal? floorf(self.size.width - endCapLeft - 1.0) : 0.0);
	
	return [self resizableImageWithCapInsets:capInsets];
}

- (UIImage *) drawnImage
{
	UIGraphicsBeginImageContextWithOptions(self.size, YES, self.scale);
	
	[self drawAtPoint:CGPointZero];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return image;
}

+ (UIImage *) cachedImageWithData:(NSData *)data
{
	CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef) data, NULL);

	UIImage *image = [self imageFromSource:source];
		
	CFRelease(source);
	
	return image? : [UIImage imageWithData:data];
}

+ (UIImage *) cachedImageWithFile:(NSString *)path
{
	CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef) path, NULL);
	
	UIImage *image = [self imageFromSource:source];

	CFRelease(source);
	
	return image? : [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *) imageFromSource:(CGImageSourceRef)source
{
	if (source) {
		static NSDictionary *cacheOptionsDict = nil;
		static dispatch_once_t cacheOptionsToken = 0;
		dispatch_once(&cacheOptionsToken, ^{
			cacheOptionsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
														   forKey:(id)kCGImageSourceShouldCache];
		});
		
		CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, 0, (__bridge CFDictionaryRef)cacheOptionsDict);
		UIImage *image = [UIImage imageWithCGImage:cgImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
		CGImageRelease(cgImage);
		return image;
	}
	return nil;
}

- (UIImage *)blurredImageWithRadius:(CGFloat)radius
						 iterations:(NSUInteger)iterations
					scaleDownFactor:(NSUInteger)scaleDownFactor
						 saturation:(CGFloat)saturation
						  tintColor:(UIColor *)tintColor
							   crop:(CGRect)crop
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
	
	if (CGRectIsEmpty(crop)) {
		crop = CGRectMake(0, 0, self.size.width, self.size.height);
	}
	CGImageRef sourceImageRef = CGImageCreateWithImageInRect(self.CGImage, crop);
	
	CGColorSpaceRef sourceColorRef = CGImageGetColorSpace(sourceImageRef);
	CGBitmapInfo sourceBitmapInfo = CGImageGetBitmapInfo(sourceImageRef);

	// scale down image
	NSUInteger sourceWidth = CGImageGetWidth(sourceImageRef);
	NSUInteger sourceHeight = CGImageGetHeight(sourceImageRef);
	
	unsigned char *sourceData = (unsigned char*) calloc(sourceWidth * sourceHeight * bytesPerPixel, sizeof(unsigned char));
	
	vImage_Buffer sourceBuffer = {
        .data = sourceData,
        .height = sourceHeight,
        .width = sourceWidth,
        .rowBytes = CGImageGetBytesPerRow(sourceImageRef)
    };
	vImage_Buffer destBuffer = sourceBuffer;
	CGImageRef scaledImageRef = sourceImageRef;
	
	if (scaleDownFactor > 1)
	{
		CGContextRef context = CGBitmapContextCreate(sourceData,
													 sourceBuffer.width,
													 sourceBuffer.height,
													 bitsPerComponent,
													 sourceBuffer.rowBytes,
													 sourceColorRef,
													 sourceBitmapInfo);
		
		CGContextDrawImage(context,
						   CGRectMake(0, 0, sourceBuffer.width, sourceBuffer.height),
						   sourceImageRef);
		
		CGContextRelease(context);
		
		NSUInteger destWidth = sourceBuffer.width / scaleDownFactor;
		NSUInteger destHeight = sourceBuffer.height / scaleDownFactor;
		
		unsigned char *destData = (unsigned char*) calloc(destWidth * destHeight * bytesPerPixel, sizeof(unsigned char));
		
		destBuffer.data = destData;
		destBuffer.height = destHeight;
		destBuffer.width = destWidth;
		destBuffer.rowBytes = bytesPerPixel * destWidth;
		
		vImageScale_ARGB8888 (&sourceBuffer, &destBuffer, NULL, kvImageNoInterpolation);
		
		free(sourceData);
		
		CGContextRef scaledContext = CGBitmapContextCreate(destData,
														   destBuffer.width,
														   destBuffer.height,
														   bitsPerComponent,
														   destBuffer.rowBytes,
														   sourceColorRef,
														   sourceBitmapInfo);
		
		scaledImageRef = CGBitmapContextCreateImage(scaledContext);
		CGContextRelease(scaledContext);
		free(destData);
	}
	
	CGImageRelease(sourceImageRef);
	
	// blur
    //boxsize must be an odd integer
    uint32_t boxSize = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;
    
	// setup image buffers for blurring
	sourceBuffer.width = destBuffer.width;
	sourceBuffer.height = destBuffer.height;
	sourceBuffer.rowBytes = destBuffer.rowBytes;
	size_t bytes = sourceBuffer.rowBytes * sourceBuffer.height;
    sourceBuffer.data = malloc(bytes);
    destBuffer.data = malloc(bytes);
    
    //create temp buffer
    void *tempBuffer = malloc((size_t)vImageBoxConvolve_ARGB8888(&sourceBuffer,
																 &destBuffer, NULL, 0, 0, boxSize, boxSize,
                                                                 NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    
    //copy image data
    CFDataRef dataSource = CGDataProviderCopyData(CGImageGetDataProvider(scaledImageRef));
    memcpy(sourceBuffer.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
	CGImageRelease(scaledImageRef);
    
    for (NSUInteger i = 0; i < iterations; i++)
    {
        //perform blur
        vImageBoxConvolve_ARGB8888(&sourceBuffer, &destBuffer, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        
        //swap buffers
        void *temp = sourceBuffer.data;
        sourceBuffer.data = destBuffer.data;
        destBuffer.data = temp;
    }
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(sourceBuffer.data,
											 sourceBuffer.width,
											 sourceBuffer.height,
                                             bitsPerComponent,
											 sourceBuffer.rowBytes,
											 sourceColorRef,
                                             sourceBitmapInfo);
    
	BOOL hasSaturationChange = fabs(saturation - 1.) > __FLT_EPSILON__;
	if (hasSaturationChange)
	{
		CGFloat s = saturation;
		CGFloat floatingPointSaturationMatrix[] = {
			0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
			0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
			0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
			0,                    0,                    0,					  1,
		};
		
		const int32_t divisor = 256;
		NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
		int16_t saturationMatrix[matrixSize];
		
		for (NSUInteger i = 0; i < matrixSize; ++i) {
			saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
		}
		
		vImageMatrixMultiply_ARGB8888(&destBuffer,
									  &sourceBuffer,
									  saturationMatrix,
									  divisor,
									  NULL,
									  NULL,
									  kvImageNoFlags);
	}
	
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f)
    {
        CGContextSetFillColorWithColor(ctx, tintColor.CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, sourceBuffer.width, sourceBuffer.height));
    }

    //create image from context
    CGImageRef blurredImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:blurredImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(blurredImageRef);
    CGContextRelease(ctx);
    free(sourceBuffer.data);
	free(destBuffer.data);
    return image;
}


@end
