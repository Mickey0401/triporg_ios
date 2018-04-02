//
//  TZCityWithDesc.h
//  Triporg
//
//  Created by Koldo Ruiz on 07/11/13.
//
//

#import "TZMappedObject.h"

@interface TZCityWithDesc : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *recomendations;
@property (nonatomic, copy) NSString *public_transport;
@property (nonatomic, copy) NSString *information_offices;
@property (nonatomic, copy) NSString *office_hours;
@property (nonatomic, copy) NSString *description_author;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSData *cacheCityImage;
@property (nonatomic, copy) NSString *image_author;
@property (nonatomic, copy) NSString *public_url;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lon;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSArray *pois;
@property (nonatomic, copy) NSArray *contacts;
@property (nonatomic, copy) NSArray *services;

@end
