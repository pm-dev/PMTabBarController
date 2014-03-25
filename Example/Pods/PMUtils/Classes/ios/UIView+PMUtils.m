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
    //cache nib to prevent unnecessary filesystem access
    static NSCache *nibCache = nil;
    if (!nibCache) {
        nibCache = [[NSCache alloc] init];
    }
    
    NSString *name = [self nibName];
    UINib *nib = [nibCache objectForKey:name];
    
    if (!nib) {
        nib = [UINib nibWithNibName:name bundle:nil];
        [nibCache setObject:nib?: [NSNull null]  forKey:name];
    }
    else if ([nib isEqual:[NSNull null]]) {
        nib = nil;
    }
    
	return nib;
}

+ (instancetype) instanceFromNibWithOwner:(id)ownerOrNil
{
    NSArray *contents = [[self nib] instantiateWithOwner:ownerOrNil options:nil];
    UIView *view = [contents count]? [contents objectAtIndex:0]: nil;
    NSAssert ([view isKindOfClass:self], @"First object in nib '%@' was '%@'. Expected '%@'", [self nibName], view, self);
    return view;
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

#pragma mark - Layout


- (void) centerInRect:(CGRect)rect forDirection:(PMDirection)direction;
{
    CGRect frame = self.frame;
    
    if (direction & PMDirectionHorizontal) {
        frame.origin.x = floorf((rect.size.width - frame.size.width) / 2.0f + rect.origin.x);
    }
    
    if (direction & PMDirectionVertical) {
        frame.origin.y = floorf((rect.size.height - frame.size.height) / 2.0f + rect.origin.y);
    }
    
    self.frame = frame;
}

@end
