//
//  TZCityInfoController.h
//  Triporg
//
//  Created by Koldo Ruiz on 07/11/13.
//
//

#import <UIKit/UIKit.h>
#import "UIImage+Additions.h"
#import <Social/Social.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>


@class TZCityWithDesc;

@interface TZCityInfoController : UIViewController <UIActionSheetDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, MKMapViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate , MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate>{
    CGFloat _descriptionHeight;
    CGFloat _recomendationHeight;
    CGFloat _transportHeight;
    CGFloat _tourismHeight;
    CGFloat _shopHeight;
    UIImage *_headerImage;
    NSMutableData *_imageData;
    SLComposeViewController *mySLComposerSheet;
}

@property (nonatomic, strong) TZCityWithDesc *eventShow;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIPopoverController *popover;

@end
