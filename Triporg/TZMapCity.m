//
//  TZMapCity.m
//  Triporg
//
//  Created by Koldo Ruiz on 10/04/14.
//
//

#import "TZMapCity.h"
#import "TZMapCityCoord.h"

@implementation TZMapCity

@synthesize topleft;
@synthesize bottomright;
@synthesize center;

+ (void)initialize
{
    [super initialize];
    
    [self hasOne:@"topleft" ofClass:[TZMapCityCoord class]];
    [self hasOne:@"bottomright" ofClass:[TZMapCityCoord class]];
    [self hasOne:@"center" ofClass:[TZMapCityCoord class]];
}

@end
