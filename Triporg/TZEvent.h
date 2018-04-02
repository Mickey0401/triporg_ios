//
//  TZEvent.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZMappedObject.h"

typedef enum {
    TZEventStatusOut = 0,
    TZEventStatusTriporgCriteria = 1,
    TZEventStatusIn = 2
} TZEventStatus;

@interface TZEvent : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *description_author;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSNumber *location_id;
@property (nonatomic, copy) NSString *type_location;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lon;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSNumber *floor;
@property (nonatomic, copy) NSString *postcode;
@property (nonatomic, copy) NSString *public_url;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSData *cacheEventImage;
@property (nonatomic, copy) NSString *image_author;
@property (nonatomic, copy) NSString *purchase_link;
@property (nonatomic , copy) NSArray *calendar;
@property (nonatomic , copy) NSArray *contacts;
@property (nonatomic , copy) NSNumber *rate;

//show events
@property (nonatomic, copy) NSNumber *id_location;
@property (nonatomic, copy) NSString *name_location;
@property (nonatomic, copy) NSNumber *status;


@end
