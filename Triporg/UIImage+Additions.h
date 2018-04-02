//
//  UIImage+Additions.h
//  Triporg
//
//  Created by Endika Salas on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

- (UIImage *)tintImageWithColor:(UIColor *)tintColor;
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;

@end
