//
//  UIDevice+PMUtils.h
//  
//
//  Created by Peter Meyers on 3/1/14.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (PMUtils)

+ (int)hardwareCores;

+ (size_t)hardwareRam;

+ (NSString *) machine;

+ (uint64_t)availableSpaceForRootVolume;

@end
