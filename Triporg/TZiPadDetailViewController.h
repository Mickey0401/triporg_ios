//
//  TZiPadDetailViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 17/03/14.
//
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"
#import <Social/Social.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>

@class TZEvent;

enum TZTripItemDetailTypeiPad {
    TZTripItemTypeEventiPad = 0,
    TZTripItemTypeLocationiPad = 1,
};

@interface TZiPadDetailViewController : UIViewController <NSURLConnectionDelegate, DLStarRatingDelegate, MKMapViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    CGFloat _descriptionHeight;
    CGFloat _timeTableHeight;
    UIImage *_headerImage;
    NSMutableData *_imageData;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TZEvent *eventShow;
@property (nonatomic) enum TZTripItemDetailTypeiPad type;
@property (nonatomic, weak) NSString *isShowing;

@end
