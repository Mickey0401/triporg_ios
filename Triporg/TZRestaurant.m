//
//  TZRestaurant.m
//  Triporg
//
//  Created by Koldo Ruiz on 29/11/13.
//
//

#import "TZRestaurant.h"

@implementation TZRestaurant

@synthesize id;
@synthesize name;
@synthesize lat;
@synthesize lon;


- (CLLocationCoordinate2D)coordinate
{
    return (CLLocationCoordinate2D) {
        .latitude = self.lat.floatValue,
        .longitude = self.lon.floatValue,
    };
}

- (NSString *)title
{
    return self.name;
}

@end

