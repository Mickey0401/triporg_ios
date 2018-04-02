//
//  TZCheckUser.h
//  Triporg
//
//  Created by Koldo Ruiz on 22/07/13.
//
//

#import "TZMappedObject.h"

@interface TZCheckUser : TZMappedObject

@property (nonatomic, copy) NSString *found;
@property (nonatomic, copy) NSString *message;

@end
