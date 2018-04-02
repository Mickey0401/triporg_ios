//
//  TZEvent.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZEvent.h"
#import "TZContact.h"
#import "TZCalendar.h"

@implementation TZEvent

@synthesize id;
@synthesize name;
@synthesize description;
@synthesize description_author;
@synthesize location;
@synthesize location_id;
@synthesize type_location;
@synthesize duration;
@synthesize color;
@synthesize lat;
@synthesize lon;
@synthesize country;
@synthesize region;
@synthesize city;
@synthesize address;
@synthesize floor;
@synthesize postcode;
@synthesize public_url;
@synthesize image;
@synthesize cacheEventImage;
@synthesize image_author;
@synthesize purchase_link;
@synthesize contacts;
@synthesize rate;
@synthesize calendar;

//show events
@synthesize id_location;
@synthesize name_location;
@synthesize status;


+ (void)initialize
{
    [super initialize];
    
    [self hasOne:@"calendar" ofClass:[TZCalendar class]];
    [self hasOne:@"contacts" ofClass:[TZContact class]];
}


@end
