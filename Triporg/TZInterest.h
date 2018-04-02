//
//  TZInterest.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 10/18/12.
//
//

#import "TZMappedObject.h"

@interface TZInterest : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *value;
@property (nonatomic, copy) NSArray *children;

@end
