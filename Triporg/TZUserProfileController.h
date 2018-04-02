//
//  TZUserProfileController.h
//  Triporg
//
//  Created by Endika Salas on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuickDialog.h>
#import <QuartzCore/QuartzCore.h>

extern NSString *const kTZUserLogout;

@interface TZUserProfileController : QuickDialogController <QuickDialogEntryElementDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) NSString *areaString;
@property (nonatomic, strong) UIPopoverController *popover;

+ (void)rootElement:(TZUserProfileController *)delegate callback:(void(^)(QRootElement *))callback;
- (id)initWithCallback:(void(^)(TZUserProfileController *))callback;


@end
