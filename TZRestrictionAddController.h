//
//  TZRestrictionViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 03/09/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface TZRestrictionAddController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MKMapView *mapRestrictView;
@property (nonatomic, strong) NSNumber *restrictionNumber;
@property (nonatomic, strong) IBOutlet UISearchBar *searcher;
@property  (nonatomic, strong ) IBOutlet UITextField *nombreCita;
@property (nonatomic, strong) IBOutlet UITextField *editStartDate;
@property (nonatomic, strong) IBOutlet UITextField *editEndDate;
@property  (nonatomic, weak ) IBOutlet UILabel *labelName;
@property (nonatomic, weak) IBOutlet UILabel *labelStart;
@property (nonatomic, weak) IBOutlet UILabel *labelEnd;

@end
