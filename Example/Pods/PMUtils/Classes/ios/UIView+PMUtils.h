//
//  UIView+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, PMDirection) {
    PMDirectionVertical = 1 << 0,
    PMDirectionHorizontal = 1 << 1
};

@interface UIView (PMUtils)

+ (NSString *) nibName;

+ (UINib *) nib;

+ (instancetype) instanceFromNibWithOwner:(id)ownerOrNil;

- (void) removeSubviews;

- (UIImage *)blurredViewWithRadius:(CGFloat)radius
						iterations:(NSUInteger)iterations
				   scaleDownFactor:(NSUInteger)scaleDownFactor
						saturation:(CGFloat)saturation
						 tintColor:(UIColor *)tintColor
							  crop:(CGRect)crop;

#pragma mark - Layout

- (void) centerInRect:(CGRect)rect forDirection:(PMDirection)direction;

- (void) setFX:(CGFloat)x;

- (void) setFY:(CGFloat)y;

- (void) setFOrigin:(CGPoint)origin;

- (void) setFWidth:(CGFloat)width;

- (void) setFHeight:(CGFloat)width;

- (void) setFSize:(CGSize)size;

- (void) setBWidth:(CGFloat)width;

- (void) setBHeight:(CGFloat)height;

- (void) setBSize:(CGSize)size;

@end
