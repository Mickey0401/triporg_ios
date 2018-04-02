//
//  TZPois.h
//  Triporg
//
//  Created by Koldo Ruiz on 08/11/13.
//
//

#import "TZMappedObject.h"

@interface TZPois : TZMappedObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lon;

@end
