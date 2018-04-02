//
//  TZTripEventHeader.h
//  Triporg
//
//  Created by Endika Salas on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TZTripEventHeader : UIView

@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, copy) void(^showMapCallback)(TZTripEventHeader*);

@end
