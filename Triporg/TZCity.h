//
//  TZCity.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZMappedObject.h"

@interface TZCity : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *nombre;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) UIImage *imageSaved;
@property (nonatomic, copy) NSString *ver;
@property (nonatomic, copy) NSArray *map;

@end
