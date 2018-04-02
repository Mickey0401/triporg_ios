//
//  TZComment.h
//  Triporg
//
//  Created by Koldo Ruiz on 04/10/13.
//
//

#import "TZMappedObject.h"

@interface TZComment : TZMappedObject

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSNumber *user_id;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSNumber *value;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *date;

@end
