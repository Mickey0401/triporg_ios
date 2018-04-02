//
//  NSArray+Additions.m
//  OpenERP-Client
//
//  Created by Endika Gutiérrez Salas on 5/18/12.
//  Copyright (c) 2012 EPD. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSArray *)collect:(id(^)(id))block
{
    NSMutableArray *collectedArray = [NSMutableArray arrayWithCapacity:self.count];
    for (id item in self) {
        id obj = block(item);
        if (obj)
            [collectedArray addObject:obj];
    }
    return collectedArray;
}

- (NSDictionary *)asIndexedDictionaryWithKey:(id(^)(id))block
{
    NSArray *keys = [self collect:block];
    return [NSDictionary dictionaryWithObjects:self forKeys:keys];
}

- (float)maxWithBlock:(float(^)(id))block
{
    if (self.count == 0)
        return 0;
    
    float max = block([self objectAtIndex:0]);
    
    for (id obj in self) {
        float val = block(obj);
        if (val > max)
            max = val;
    }
    return max;
}

- (float)minWithBlock:(float(^)(id))block
{
    if (self.count == 0)
        return 0;
    
    float min = block([self objectAtIndex:0]);
    
    for (id obj in self) {
        float val = block(obj);
        if (val < min)
            min = val;
    }
    return min;
}

@end


@implementation NSMutableArray (Additions)

- (void)insertObjects:(NSArray *)array transform:(id(^)(id))block;
{
    for (id item in array) {
        id obj = block(item);
        if (obj)
            [self addObject:obj];
    }
}

@end
