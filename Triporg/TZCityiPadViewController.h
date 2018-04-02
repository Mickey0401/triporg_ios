//
//  TZCityiPadViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 24/03/14.
//
//

#import <UIKit/UIKit.h>
#import "UIImage+Additions.h"
#import <Social/Social.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>


@class TZCityWithDesc;

@interface TZCityiPadViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, MKMapViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    CGFloat _descriptionHeight;
    CGFloat _recomendationHeight;
    CGFloat _transportHeight;
    CGFloat _tourismHeight;
    CGFloat _shopHeight;
    UIImage *_headerImage;
    NSMutableData *_imageData;
}

@property (nonatomic, strong) TZCityWithDesc *eventShow;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

