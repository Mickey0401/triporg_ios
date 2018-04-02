//
//  TZLocation.h
//  Triporg
//
//  Created by Koldo Ruiz on 21/10/13.
//
//

#import "TZMappedObject.h"

@interface TZLocation : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *nombre;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) UIImage *imageSaved;

@end
