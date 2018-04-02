//
//  TZMessage.h
//  Triporg
//
//  Created by Koldo Ruiz on 06/05/14.
//
//

#import "TZMappedObject.h"

@interface TZMessage : TZMappedObject

@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *msg_show;
@property (nonatomic, copy) NSNumber *msg_version;
@property (nonatomic, copy) NSString *msg_repeat;
@property (nonatomic, copy) NSString *logout;

@end
