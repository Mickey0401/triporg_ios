//
//  TZiPadListViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 11/03/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TZTrip;

@interface TZiPadListViewController : UIViewController <UISearchBarDelegate, UIAlertViewDelegate , UITableViewDelegate , UITableViewDataSource, UIScrollViewDelegate, MKMapViewDelegate, UIPopoverControllerDelegate> {
    NSArray *_eventsByDays;
    NSArray *_allEvents;
    NSArray *_filteredEvents;
    BOOL _tripHasChange;
}

@property (nonatomic, retain) TZTrip *trip;
@property (nonatomic) BOOL editing;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapControl;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) UIPopoverController *popover;

- (IBAction)MapTypeChange:(id)sender;


@end
