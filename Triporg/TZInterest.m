//
//  TZInterest.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 10/18/12.
//
//

#import "TZInterest.h"

@implementation TZInterest

@synthesize id;
@synthesize name;
@synthesize value;
@synthesize children;

+ (void)initialize
{
    [super initialize];
    
    [self hasMany:@"children" ofClass:[TZInterest class]];
}

@end
