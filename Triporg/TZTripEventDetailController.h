//
//  TZTripEventDetailController.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"
#import <Social/Social.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>

@class TZEvent;

enum TZTripItemDetailType {
    TZTripItemTypeEvent = 0,
    TZTripItemTypeLocation = 1,
};

@interface TZTripEventDetailController : UIViewController <UIActionSheetDelegate, NSURLConnectionDelegate, DLStarRatingDelegate, MKMapViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate , MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate> {
    CGFloat _descriptionHeight;
    CGFloat _timeTableHeight;
    UIImage *_headerImage;
    NSMutableData *_imageData;
    NSInteger _openTwitterIndex;
    NSInteger _openFacebookIndex;
    SLComposeViewController *mySLComposerSheet;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TZEvent *eventShow;
@property (nonatomic) enum TZTripItemDetailType type;
@property (nonatomic, weak) NSString *isShowing;
@property (nonatomic, strong) UIPopoverController *popover;

@end
