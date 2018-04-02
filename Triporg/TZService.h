//
//  TZService.h
//  Triporg
//
//  Created by Koldo Ruiz on 14/11/13.
//
//

#import "TZMappedObject.h"

@interface TZService : TZMappedObject

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *abbreviation;

@end
