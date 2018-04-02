//
//  TZTripEvent.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTripEvent.h"

@implementation TZTripEvent

@synthesize id;
@synthesize name;
@synthesize id_location;
@synthesize name_location;
@synthesize start;
@synthesize end;
@synthesize color;
@synthesize duration;
@synthesize distance_minutes;
@synthesize distance_meters;
@synthesize lat;
@synthesize lon;
@synthesize image;
@synthesize events;
@synthesize Indice;
@synthesize cacheImage;


+ (void)initialize
{
    static BOOL initialized = NO;
    if (initialized)
        return;
    
    initialized = YES;
    
    [super initialize];
   
    [self hasOne:@"events" ofClass:[TZEvent class]];
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

- (NSString *)subtitle
{
    return self.name_location;
}


@end
