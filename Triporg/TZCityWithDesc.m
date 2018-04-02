//
//  TZCityWithDesc.m
//  Triporg
//
//  Created by Koldo Ruiz on 07/11/13.
//
//

#import "TZCityWithDesc.h"
#import "TZPois.h"
#import "TZContact.h"
#import "TZService.h"

@implementation TZCityWithDesc

@synthesize id;
@synthesize name;
@synthesize description;
@synthesize recomendations;
@synthesize public_transport;
@synthesize information_offices;
@synthesize office_hours;
@synthesize description_author;
@synthesize image;
@synthesize image_author;
@synthesize public_url;
@synthesize lat;
@synthesize lon;
@synthesize country;
@synthesize region;
@synthesize pois;
@synthesize contacts;
@synthesize services;
@synthesize cacheCityImage;


+ (void)initialize
{
    [super initialize];
    [self hasOne:@"pois" ofClass:[TZPois class]];
    [self hasOne:@"contacts" ofClass:[TZContact class]];
    [self hasOne:@"services" ofClass:[TZService class]];
}

@end
