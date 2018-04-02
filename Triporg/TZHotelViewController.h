//
//  TZHotelViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 02/12/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TZHotelViewController : UIViewController <UISearchBarDelegate , MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapHotelView;
@property (nonatomic, strong) UISearchBar *searchBar;


@end
