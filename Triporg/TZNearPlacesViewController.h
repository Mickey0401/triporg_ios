//
//  TZNearPlacesViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 28/04/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TZNearPlacesViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableArray *dataArray;
    NSArray *_filteredEvents;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapControl;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showListButton;

- (IBAction)MapTypeChange:(id)sender;
- (IBAction)showPoisList:(id)sender;

@end
