//
//  TZCity.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZCity.h"
#import "TZMapCity.h"

@implementation TZCity

@synthesize id;
@synthesize nombre;
@synthesize country;
@synthesize image;
@synthesize imageSaved;
@synthesize ver;
@synthesize map;


+ (void)initialize
{
    [super initialize];
    
    [self hasOne:@"map" ofClass:[TZMapCity class]];
    
}



@end
