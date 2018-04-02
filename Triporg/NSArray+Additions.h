//
//  NSArray+Additions.h
//  OpenERP-Client
//
//  Created by Endika Gutiérrez Salas on 5/18/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

- (NSDictionary *)asIndexedDictionaryWithKey:(id(^)(id))block;
- (NSArray *)collect:(id(^)(id))block;

- (float)maxWithBlock:(float(^)(id))block;
- (float)minWithBlock:(float(^)(id))block;

@end

@interface NSMutableArray (Additions)

- (void)insertObjects:(NSArray *)array transform:(id(^)(id))block;

@end
