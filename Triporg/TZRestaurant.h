//
//  TZRestaurant.h
//  Triporg
//
//  Created by Koldo Ruiz on 29/11/13.
//
//

#import "TZMappedObject.h"
#import <MapKit/MapKit.h>

@interface TZRestaurant : TZMappedObject <MKAnnotation>

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lon;

@end
