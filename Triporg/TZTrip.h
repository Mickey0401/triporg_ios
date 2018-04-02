//
//  TZTrip.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZMappedObject.h"


@interface TZTrip : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *trip_name;
@property (nonatomic, copy) NSDate *start;
@property (nonatomic, copy) NSDate *end;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSNumber *region_id;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSData *imageFinal;
@property (nonatomic, copy) NSData *cacheImage;
@property (nonatomic, copy) NSNumber *user_id;
@property (nonatomic, copy) NSNumber *center_lat;
@property (nonatomic, copy) NSNumber *center_lon;
@property (nonatomic, retain) NSArray *events;
@property (nonatomic, retain) NSNumber *city_id;
@property (nonatomic, copy) NSData *mapCache;
@property (nonatomic, copy) NSNumber *downloaded;
@property (nonatomic, copy) NSString *public_url;

@end
