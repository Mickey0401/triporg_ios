//
//  GooglePoi.h
//  Triporg
//
//  Created by Koldo Ruiz on 08/05/14.
//
//

#import "TZMappedObject.h"
#import <MapKit/MapKit.h>


@interface GooglePoi : TZMappedObject <MKAnnotation>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lon;

@end
