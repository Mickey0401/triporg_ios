//
//  TZiPadMapViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 26/03/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@class TZTrip;

@interface TZiPadMapViewController : UIViewController <MKMapViewDelegate, UIScrollViewDelegate> {
    BOOL _navigate;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *mapControl;
@property (nonatomic, strong) NSArray *tripEvents;
@property (nonatomic, strong) TZTrip *trip;
@property (weak, nonatomic) NSNumber *cityId;
@property(nonatomic, strong) UITapGestureRecognizer *singleTap;
@property(nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property(nonatomic, strong) UITapGestureRecognizer *twoFingerTap;
@property (nonatomic, assign) NSInteger mapTypeMemorizer;

- (IBAction)MapTypeChange:(id)sender;

@end
