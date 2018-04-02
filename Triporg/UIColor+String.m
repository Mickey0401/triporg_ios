//
//  UIColor+String.m
//  Triporg
//
//  Created by Endika Salas on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+String.h"

#define HALFBYTE_FROM_HEX(c) ((c) < 'A' ? ((c) - '0') : ((c) < 'a' ? (c) - 'A' + 10 : (c) - 'a' + 10))
#define BYTE_FROM_HEX(s) (HALFBYTE_FROM_HEX(*s) * 16 + HALFBYTE_FROM_HEX(*(s + 1)))

@implementation UIColor (String)

+ (UIColor *)colorWithString:(NSString *)color
{
    if (color.length < 7)
        return nil;
    
    const char *cColor = [color cStringUsingEncoding:NSUTF8StringEncoding];
    
    ++cColor;
    unsigned char r = BYTE_FROM_HEX(cColor);
    cColor += 2;
    unsigned char g = BYTE_FROM_HEX(cColor);
    cColor += 2;
    unsigned char b = BYTE_FROM_HEX(cColor);
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1];
}

@end
