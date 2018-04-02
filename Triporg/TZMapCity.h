//
//  TZMapCity.h
//  Triporg
//
//  Created by Koldo Ruiz on 10/04/14.
//
//

#import "TZMappedObject.h"

@interface TZMapCity : TZMappedObject

@property (nonatomic, copy) NSArray *topleft;
@property (nonatomic, copy) NSArray *bottomright;
@property (nonatomic, copy) NSArray *center;

@end
