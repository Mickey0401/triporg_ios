//
//  TZTrip.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTrip.h"
#import "TZTripEvent.h"

@implementation TZTrip

@synthesize id;
@synthesize trip_name;
@synthesize start;
@synthesize end;
@synthesize country;
@synthesize region;
@synthesize region_id;
@synthesize city;
@synthesize user_id;
@synthesize center_lat;
@synthesize center_lon;
@synthesize image;
@synthesize imageFinal;
@synthesize cacheImage;
@synthesize city_id;
@synthesize mapCache;
@synthesize downloaded;
@synthesize public_url;
@synthesize events;

+ (void)initialize
{
    [super initialize];
    
    [self hasMany:@"events" ofClass:[TZTripEvent class]];
}

@end
