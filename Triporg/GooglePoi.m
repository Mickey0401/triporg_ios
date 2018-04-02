//
//  GooglePoi.m
//  Triporg
//
//  Created by Koldo Ruiz on 08/05/14.
//
//

#import "GooglePoi.h"

@implementation GooglePoi

@synthesize name;
@synthesize lat;
@synthesize lon;

+ (void)initialize
{
    [super initialize];
    
}

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
