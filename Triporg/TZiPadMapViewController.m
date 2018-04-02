//
//  TZiPadMapViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 26/03/14.
//
//

#import "TZiPadMapViewController.h"
#import "NSArray+Additions.h"
#import "TZTrip.h"
#import "TZTripEvent.h"
#import "TZEvent.h"
#import "TZRestaurant.h"
#import "UIColor+String.h"
#import "UIImage+Additions.h"
#import "TZTriporgManager.h"
#import "TZTripEventDetailController.h"
#import "MBProgressHUD.h"
#import "GooglePoi.h"

#define ZOOM_STEP 1.5


static TZTripEventDetailController *eventDetail;

@interface TZiPadMapViewController ()
{
    UIButton *locateButton;
    UIButton *restaurantButton;
    UIScrollView *scrollView;
    UIImageView *mapImageView;
    NSString *versioniOS;
    NSInteger zoom;
    BOOL navigationBarInvisible;
    BOOL restaurantActive;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end


@implementation TZiPadMapViewController{
    NSArray *restaurantsArray;
    NSArray *miniRestaurantsArray;
}

@synthesize mapView = _mapView;
@synthesize trip = _trip;
@synthesize tripEvents = _tripEvents;
@synthesize doubleTap,singleTap, twoFingerTap,cityId, mapControl;
@synthesize mapTypeMemorizer;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    zoom = 0;
    navigationBarInvisible = NO;
    
    mapControl.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    mapControl.alpha = 0.9;
    
    if (!_trip.mapCache)
    {
        versioniOS = [[UIDevice currentDevice] systemVersion];
        
        restaurantActive = NO;
        
        if (!_tripEvents)
        {
            _tripEvents = _trip.events;
        }
        
        CGFloat maxLat = [_tripEvents maxWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
        CGFloat minLat = [_tripEvents minWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
        CGFloat maxLng = [_tripEvents maxWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
        CGFloat minLng = [_tripEvents minWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
        
        self.mapView.region = (MKCoordinateRegion) {
            .center = {
                .latitude = (maxLat + minLat) / 2.0f,
                .longitude = (maxLng + minLng) / 2.0f
            },
            .span = {
                .latitudeDelta = maxLat - minLat,
                .longitudeDelta = maxLng - minLng
            }
        };
        
        locateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
        [locateButton setImage:[UIImage imageNamed:@"Navigate"] forState:UIControlStateNormal];
        [locateButton addTarget:self action:@selector(showUserHeadding:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *gpsButton = [[UIBarButtonItem alloc] initWithCustomView:locateButton];
        
        restaurantButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 31, 31)];
        [restaurantButton setImage:[UIImage imageNamed:@"mapMarker-restaurant"] forState:UIControlStateNormal];
        restaurantButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [restaurantButton addTarget:self action:@selector(activateRestaurants:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *tenedorButton = [[UIBarButtonItem alloc] initWithCustomView:restaurantButton];
        
        NSArray *buttonsArray = [[NSArray alloc] initWithObjects:gpsButton, tenedorButton, nil];
        
        self.navigationItem.rightBarButtonItems = buttonsArray;
        
        restaurantsArray = [[NSArray alloc] init];
        miniRestaurantsArray = [[NSArray alloc] init];
        
        if (cityId != nil)
        {
            [[TZTriporgManager sharedManager] showRestaurantsWithId:cityId callback:^(id resp) {
                if ([resp isKindOfClass:[NSError class]])
                {
                    
                }
                else
                {
                    restaurantsArray = resp;
                }
            }];
        }
        
        [self.mapView addAnnotations:_tripEvents];
        
        if ([versioniOS hasPrefix:@"6."])
        {
            
        }
        else
        {
            self.mapView.showsBuildings = YES;
        }
        
        mapControl.selectedSegmentIndex = mapTypeMemorizer;
        
        switch (mapTypeMemorizer)
        {
            case 0:
                [self.mapView setMapType:MKMapTypeStandard];
                break;
                
            case 1:
                [self.mapView setMapType:MKMapTypeHybrid];
                break;
                
            case 2:
                [self.mapView setMapType:MKMapTypeSatellite];
                break;
        }
    }
    else
    {
        [self.mapView removeFromSuperview];
        self.mapView.delegate = nil;
        self.mapView = nil;
        
        mapControl.hidden = YES;
        mapImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *imageForMap = [UIImage imageWithData:_trip.mapCache];
        mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, imageForMap.size.width, imageForMap.size.height)];
        mapImageView.image = imageForMap;
        mapImageView.userInteractionEnabled = YES;
        mapImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        
        [scrollView setContentSize:CGSizeMake(mapImageView.frame.size.width, mapImageView.frame.size.height)];
        
        scrollView.bouncesZoom = YES;
        scrollView.delegate = self;
        scrollView.clipsToBounds = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        CGFloat minimumScale = [scrollView frame].size.width  / [mapImageView frame].size.width;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = minimumScale;
        scrollView.zoomScale = minimumScale;
        
        singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        
        [doubleTap setNumberOfTapsRequired:2];
        [twoFingerTap setNumberOfTouchesRequired:2];
        
        [scrollView addGestureRecognizer:singleTap];
        [mapImageView addGestureRecognizer:doubleTap];
        [mapImageView addGestureRecognizer:twoFingerTap];
        
        [self.view addSubview:scrollView];
        [scrollView addSubview:mapImageView];
        
        self.view.backgroundColor = [UIColor blackColor];
        
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        [self centerScrollViewContents];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.layer.opacity = 1;
}

- (void)showUserHeadding:(id)sender
{
    if (!_navigate)
    {
        self.mapView.showsUserLocation = YES;
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        _navigate = YES;
        
        [UIView transitionWithView:locateButton duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                               
                           } completion:nil];
        
        [locateButton setImage:[[UIImage imageNamed:@"Navigate"] tintImageWithColor:[UIColor colorWithString:@"#93D31B"]] forState:UIControlStateNormal];
    }
    else
    {
        self.mapView.showsUserLocation = NO;
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
        _navigate = !_navigate;
        
        [UIView transitionWithView:locateButton duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                               
                           } completion:nil];
        
        [locateButton setImage:[UIImage imageNamed:@"Navigate"] forState:UIControlStateNormal];
    }
}

- (void)activateRestaurants:(id)sender
{
    if (restaurantActive == NO)
    {
        [UIView transitionWithView:restaurantButton duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                               
                           } completion:nil];
        
        [restaurantButton setImage:[[UIImage imageNamed:@"mapMarker-restaurant"] tintImageWithColor:[UIColor colorWithString:@"#93D31B"]] forState:UIControlStateNormal];
        restaurantActive = YES;
        
        if (restaurantsArray.count > 0)
        {
            [self.mapView addAnnotations:restaurantsArray];
        }
        
        [[TZTriporgManager sharedManager] PlacesPoisWithLat:[NSString stringWithFormat:@"%f",self.mapView.region.center.latitude] lon:[NSString stringWithFormat:@"%f",self.mapView.region.center.longitude] callback:^(id resp) {
            
            if ([resp isKindOfClass:[NSError class]])
            {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                            message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                  otherButtonTitles:nil] show];
            }
            else
            {
                miniRestaurantsArray = resp;
                if (miniRestaurantsArray.count > 0)
                {
                    [self.mapView addAnnotations:miniRestaurantsArray];
                    [self.mapView reloadInputViews];
                }
            }
        }];
    }
    else
    {
        restaurantActive = NO;
        [UIView transitionWithView:restaurantButton duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                               
                           } completion:nil];
        
        [restaurantButton setImage:[UIImage imageNamed:@"mapMarker-restaurant"] forState:UIControlStateNormal];
        
        [self.mapView removeAnnotations:restaurantsArray];
        [self.mapView removeAnnotations:miniRestaurantsArray];
    }
}

- (void)detailPressed:(UIButton *)button
{
    TZTripEvent *selectedEvent = nil;
    for (TZTripEvent *event in _tripEvents)
    {
        if (event.id.integerValue == button.tag)
        {
            selectedEvent = event;
        }
    }
    if (selectedEvent)
    {
        if ([selectedEvent.id isEqualToNumber:[NSNumber numberWithInteger:0]])
        {
            return;
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        eventDetail = nil;
        eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripEventDetail"];
        
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[TZTriporgManager sharedManager] getEventWithId:selectedEvent.id callback:^(TZEvent *event) {
            
            if ([event isKindOfClass:[NSError class]])
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"")
                                                                  message:NSLocalizedString(@"El viaje no se ha podido cargar. Conéctate a Internet y vuelve a intentarlo", @"" )
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                                        otherButtonTitles:nil];
                [message show];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
            }
            else
            {
                eventDetail.eventShow = nil;
                eventDetail.eventShow = event;
                [self performSelector:@selector(goToTheDetail:) withObject:nil];
            }
        }];
    }
}

- (void)detailRestaurantPressed:(UIButton *)button
{
    TZRestaurant *selectedEvent = nil;
    for (TZRestaurant *event in restaurantsArray)
    {
        if (event.id.integerValue == button.tag)
        {
            selectedEvent = event;
        }
    }
    if (selectedEvent)
    {
        if ([selectedEvent.id isEqualToNumber:[NSNumber numberWithInteger:0]])
        {
            return;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        eventDetail = nil;
        eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripEventDetail"];
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[TZTriporgManager sharedManager] getLocationWithId:selectedEvent.id callback:^(TZEvent *event) {
            
            if ([event isKindOfClass:[NSError class]])
            {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"")
                                                                  message:NSLocalizedString(@"El viaje no se ha podido cargar. Conéctate a Internet y vuelve a intentarlo", @"" )
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                                        otherButtonTitles:nil];
                [message show];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
            else
            {
                eventDetail.eventShow = nil;
                eventDetail.eventShow = event;
                eventDetail.type = TZTripItemTypeLocation;
                [self performSelector:@selector(goToTheDetail:) withObject:nil];
            }
            
        }];
    }
}

#pragma mark Map Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[TZTripEvent class]])
    {
        TZTripEvent *annotationEvent = annotation;
        
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotationEvent reuseIdentifier:@"Annotation"];
        view.calloutOffset = CGPointMake(0, -23);
        view.centerOffset = CGPointMake(0, -23);
        
        UIImage *marker = [[UIImage imageNamed:@"MapMarker"] tintImageWithColor:[UIColor colorWithString:annotationEvent.color]];
        
        view.enabled = YES;
        view.canShowCallout = YES;
        
        UIImageView *markerView = [[UIImageView alloc] initWithImage:marker];
        markerView.frame = CGRectMake(0, 0, 45, 45);
        markerView.center = view.center;
        [view addSubview:markerView];
        
        UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(-10, -13, 20, 20)];
        number.text = [NSString stringWithFormat:@"%u", [_tripEvents indexOfObject:annotationEvent] + 1];
        number.textAlignment = NSTextAlignmentCenter;
        number.backgroundColor = [UIColor clearColor];
        [view addSubview:number];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tag = annotationEvent.id.integerValue;
        [detailButton addTarget:self action:@selector(detailPressed:) forControlEvents:UIControlEventTouchDown];
        if (detailButton.tag != 0)
        {
            view.rightCalloutAccessoryView = detailButton;
        }
        
        markerView.layer.opacity = 1;
        
        return view;
    }
    else if ([annotation isKindOfClass:[TZRestaurant class]])
    {
        TZRestaurant *annotationRestaurant = annotation;
        
        MKAnnotationView *customPinview = [[MKAnnotationView alloc]
                                           initWithAnnotation:annotationRestaurant reuseIdentifier:@"Restaurant"];
        customPinview.calloutOffset = CGPointMake(0, -22);
        
        UIImage *tenedor = [[UIImage imageNamed:@"mapMarker-restaurant"] tintImageWithColor:[UIColor colorWithString:@"#010845"]];
        
        UIImageView *markerView = [[UIImageView alloc] initWithImage:tenedor];
        markerView.frame = CGRectMake(0, 0, 40, 40);
        markerView.center = customPinview.center;
        [customPinview addSubview:markerView];
        
        customPinview.enabled = YES;
        customPinview.canShowCallout = YES;
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tag = annotationRestaurant.id.integerValue;
        [detailButton addTarget:self action:@selector(detailRestaurantPressed:) forControlEvents:UIControlEventTouchDown];
        customPinview.rightCalloutAccessoryView = detailButton;
        
        return customPinview;
    }
    else if ([annotation isKindOfClass:[GooglePoi class]])
    {
        GooglePoi *annotationMiniRestaurant = annotation;
        
        MKAnnotationView *customPinview = [[MKAnnotationView alloc]
                                           initWithAnnotation:annotationMiniRestaurant reuseIdentifier:@"Restaurant"];
        
        customPinview.calloutOffset = CGPointMake(0, -17);
        
        UIImage *tenedor = [[UIImage imageNamed:@"mapMarker-restaurant"] tintImageWithColor:[UIColor colorWithString:@"#010845"]];
        
        UIImageView *markerView = [[UIImageView alloc] initWithImage:tenedor];
        markerView.frame = CGRectMake(0, 0, 30, 30);
        markerView.center = customPinview.center;
        [customPinview addSubview:markerView];
        
        customPinview.enabled = YES;
        customPinview.canShowCallout = YES;
        
        return customPinview;
    }
    else
    {
        return nil;
    }
}

- (IBAction)MapTypeChange:(id)sender
{
    switch (((UISegmentedControl *) sender).selectedSegmentIndex)
    {
        case 0:
            [self.mapView setMapType:MKMapTypeStandard];
            break;
            
        case 1:
            [self.mapView setMapType:MKMapTypeHybrid];
            break;
            
        case 2:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
    }
}

- (void)goToTheDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:eventDetail animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mapImageView;
}

//funcion que provoca que al hacer zoom la imagen siempre este centrada
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (navigationBarInvisible == NO)
    {
        [UIView transitionWithView:self.navigationController.navigationBar duration:0.3
                           options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                               self.navigationController.navigationBar.layer.opacity = 0;
                           } completion:nil];
        
        navigationBarInvisible = YES;
    }
    else
    {
        [UIView transitionWithView:self.navigationController.navigationBar duration:0.3
                           options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                               self.navigationController.navigationBar.layer.opacity = 1;
                           } completion:nil];
        navigationBarInvisible = NO;
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (zoom == 3)
    {
        // Zooms out
        CGFloat newScale = [scrollView zoomScale] / (ZOOM_STEP * 3);
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        zoom = 0;
    }
    else
    {
        // Zoom in
        CGFloat newScale = [scrollView zoomScale] * ZOOM_STEP;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        zoom++;
    }
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (zoom != 0)
    {
        CGFloat newScale = [scrollView zoomScale] / ZOOM_STEP;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        zoom--;
    }
}

- (void)centerScrollViewContents
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = mapImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    mapImageView.frame = contentsFrame;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

@end