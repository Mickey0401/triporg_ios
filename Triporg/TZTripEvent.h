//
//  TZTripEvent.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZMappedObject.h"
#import "TZEvent.h"

#import <MapKit/MapKit.h>

@interface TZTripEvent : TZMappedObject <MKAnnotation>

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *id_location;
@property (nonatomic, copy) NSString *name_location;
@property (nonatomic, copy) NSDate *start;
@property (nonatomic, copy) NSDate *end;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSNumber *distance_minutes;
@property (nonatomic, copy) NSNumber *distance_meters;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lon;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSData *cacheImage;
@property (nonatomic, copy) NSNumber *Indice;
@property (nonatomic, retain) TZEvent *events;

@end
