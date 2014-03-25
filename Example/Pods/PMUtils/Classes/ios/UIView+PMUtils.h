//
//  UIView+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, PMDirection) {
    PMDirectionVertical = 1 << 0,
    PMDirectionHorizontal = 1 << 1
};

@interface UIView (PMUtils)

+ (NSString *) nibName;

+ (instancetype) instanceFromNibWithOwner:(id)ownerOrNil;

- (void) removeSubviews;

- (UIImage *)blurredViewWithRadius:(CGFloat)radius
						iterations:(NSUInteger)iterations
				   scaleDownFactor:(NSUInteger)scaleDownFactor
						saturation:(CGFloat)saturation
						 tintColor:(UIColor *)tintColor
							  crop:(CGRect)crop;

- (void) centerInRect:(CGRect)rect forDirection:(PMDirection)direction;

@end
