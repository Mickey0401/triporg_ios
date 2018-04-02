//
//  TZCreateTripController.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickDialog.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

extern NSString *const kTZTripCreated;

@interface TZCreateTripController : QuickDialogController <QuickDialogEntryElementDelegate , UIAlertViewDelegate>

//- (id)initWithCallback:(void(^)(TZCreateTripController *))callback;
+ (void)rootElement:(void(^)(QRootElement *))callback;


@end
