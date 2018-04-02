//
//  TZCalendar.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZMappedObject.h"

@interface TZCalendar : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *months;
@property (nonatomic, copy) NSString *days;
@property (nonatomic, copy) NSString *schedule;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *exact;

@end
