//
//  EPDMappedObject.h
//  
//
//  Created by Endika Gutiérrez Salas on 6/18/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface TZMappedObject : NSObject

+ (RKObjectMapping *)objectMapping;

+ (void)hasMany:(NSString *)property ofClass:(Class)class;
+ (void)hasOne:(NSString *)property ofClass:(Class)class;

- (id)initWithKeyValues:(NSDictionary *)dict;

- (NSDictionary *)asKeyValueDictionary;

- (NSString *)serialize;

@end
