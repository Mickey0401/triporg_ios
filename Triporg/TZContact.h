//
//  TZContact.h
//  Triporg
//
//  Created by Koldo Ruiz on 08/11/13.
//
//

#import "TZMappedObject.h"

@interface TZContact : TZMappedObject

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *abbreviation;

@end
