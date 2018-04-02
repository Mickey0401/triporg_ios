//
//  EPDMappedObject.m
//  
//
//  Created by Endika Gutiérrez Salas on 6/18/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "TZMappedObject.h"
#import <RestKit/RestKit.h>
#import "NSArray+Additions.h"
#import <objc/runtime.h>

static NSString *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[strlen(attributes) + 1];
    strcpy(buffer, attributes);
    char *attribute = strtok((char *)&buffer, ",");
    do {
        if (attribute[0] == 'T') {
            return [NSString stringWithFormat:@"%s", attribute + 1];
        }
    } while ((attribute = strtok(NULL, ",")) != NULL);
    return nil;
}

@implementation TZMappedObject

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping *mapping = [[RKObjectManager sharedManager].mappingProvider mappingForKeyPath:NSStringFromClass([self class])];
    if (!mapping) {
        mapping = [RKObjectMapping mappingForClass:self];
        [[RKObjectManager sharedManager].mappingProvider setMapping:mapping forKeyPath:NSStringFromClass([self class])];
    }
    return mapping;
}

- (id)initWithKeyValues:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        // Unpack object
        for (NSString *key in dict) {
            @try {
                id value = [dict objectForKey:key];
                
                if ([value isKindOfClass:[NSDictionary class]]) {
                    Class class = ((RKObjectMapping *)[self.class.objectMapping mappingForRelationship:key].mapping).objectClass;
                    if ([class isSubclassOfClass:[TZMappedObject class]])
                        value = [[class alloc] initWithKeyValues:value];
                    
                } else if ([value isKindOfClass:[NSArray class]]) {
                    Class class = ((RKObjectMapping *)[self.class.objectMapping mappingForRelationship:key].mapping).objectClass;
                    //NSLog(@"Mapping %@ of class %@ %i", key, class, [class isSubclassOfClass:[TZMappedObject class]]);
                    if ([class isSubclassOfClass:[TZMappedObject class]]) {
                        value = [value collect:^id(NSDictionary *d) { return [[class alloc] initWithKeyValues:d]; }];
                    }
                }
                [self setValue:value forKey:key];
                
            }
            @catch (NSException *exception) {
               // NSLog(@"Object %@ Unable to set Key:%@", NSStringFromClass([self class]), key);
            }
        }
    }
    return self;
}

+ (void)initialize
{
    RKObjectMapping *mapping = [self objectMapping];
    
//    NSUInteger outCount;
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);

    //NSLog(@"Mapping: %@", NSStringFromClass([self class]));
    
    for (NSInteger i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName) {
            @try {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                if (propertyName.length == 0)
                    continue;
                NSString *propertyType = getPropertyType(property);
                if ([propertyType rangeOfString:@"String"].location != NSNotFound
                    || [propertyType rangeOfString:@"Number"].location != NSNotFound
                    || [propertyType rangeOfString:@"Date"].location != NSNotFound) {
                    
                    [mapping mapKeyPath:propertyName toAttribute:propertyName];
                    
                }
                //NSLog(@"Mapped: %@, %@", propertyName, propertyType);
            }
            @catch (NSException *exception) {
              //  NSLog(@"Error mapping object %@: %@", NSStringFromClass(self), exception);
            }
            
        }
    }
    free(properties);
    
}


+ (void)hasMany:(NSString *)property ofClass:(Class)class
{
    RKObjectMapping *mapping = [self objectMapping];
    [mapping mapKeyPath:property toRelationship:property withMapping:[class performSelector:@selector(objectMapping)]];
}

+ (void)hasOne:(NSString *)property ofClass:(Class)class
{
    RKObjectMapping *mapping = [self objectMapping];
    [mapping mapKeyPath:property toRelationship:property withMapping:[class performSelector:@selector(objectMapping)]];
}

- (BOOL)isValidKeyValueType:(id)obj
{
    return [obj isKindOfClass:[NSString class]]
    || [obj isKindOfClass:[NSNumber class]]
    || [obj isKindOfClass:[NSDate class]]
    || [obj isKindOfClass:[NSData class]]
    || [obj isKindOfClass:[NSArray class]]
    || [obj isKindOfClass:[NSDictionary class]];
}

- (NSDictionary *)asKeyValueDictionary
{
    NSUInteger i;
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableDictionary *keyValue = [NSMutableDictionary dictionaryWithCapacity:outCount];
    
    for (i = 0; i < outCount; i++) {
        @try {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if (propName) {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                
                @try {
                    id value = [self valueForKey:propertyName];
                    
                    if ([value isKindOfClass:[NSArray class]]) {
                        value = [value collect:^id(id v) {
                            return [v isKindOfClass:[TZMappedObject class]] ? [v asKeyValueDictionary] : ([self isValidKeyValueType:value] ? v : nil);
                        }];
                    } else if ([value isKindOfClass:[TZMappedObject class]]) {
                        value = [value asKeyValueDictionary];
                    }
                    
                    if (value && [self isValidKeyValueType:value]) {
                        [keyValue setObject:value forKey:propertyName];
                    }
                    
                }
                @catch (NSException *exception) {
                   // NSLog(@"Error getting object as KeyValue: %@", exception);
                }
                
            }
        } @catch (NSException *exception) {
            
        }
    }
    free(properties);
    
    return keyValue;
}

- (NSString *)serialize
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self asKeyValueDictionary] options:0 error:nil] encoding:NSUTF8StringEncoding];
    
}

//- (NSString *)debugDescription
//{
//    return [self description];
//}
//
//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"<%@ %@>", NSStringFromClass([self class]), [self asKeyValueDictionary]];
//}

@end
