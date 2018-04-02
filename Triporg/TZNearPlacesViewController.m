//
//  TZNearPlacesViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 28/04/14.
//
//

#import "TZNearPlacesViewController.h"
#import "TZTripEvent.h"
#import "TZTriporgManager.h"
#import "TZTripEventDetailController.h"
#import "MBProgressHUD.h"
#import "NSArray+Additions.h"
#import <QuartzCore/QuartzCore.h>

static TZTripEventDetailController *eventDetail;

@interface TZNearPlacesViewController ()

@end

@implementation TZNearPlacesViewController {
    UILabel *instructionLabel;
    NSInteger poisOnScreen;
    NSMutableArray *searchArray;
    NSNumber *oldLatitude;
    NSNumber *oldLongitude;
    BOOL firstReloadDone;
    BOOL loadingPois;
}

@synthesize mapControl, showListButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Cerca de mí", @"");
    
    poisOnScreen = 0;
    loadingPois = NO;
    firstReloadDone = NO;
    
    oldLatitude = [NSNumber numberWithInteger:0];
    oldLongitude = [NSNumber numberWithInteger:0];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPois:)];
    
    mapControl.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    showListButton.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64 + 44, 0, 0, 0);
    
    CGFloat searchBarWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        searchBarWidth = 1024;
    }
    else
    {
        searchBarWidth = 320;
    }

    instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.mapView.bounds.size.width, 30)];
    instructionLabel.text = [NSString stringWithFormat:@"%d POIs", poisOnScreen];
    instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    instructionLabel.textColor = [UIColor grayColor];
    instructionLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.numberOfLines = 0;
    [instructionLabel.layer setCornerRadius:7.0f];
    [instructionLabel.layer setMasksToBounds:YES];
    [self.mapView addSubview:instructionLabel];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, searchBarWidth, 44)];
    searchBar.delegate = self;
    searchBar.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    
    // iOS Version
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        instructionLabel.hidden = YES;
    }
    else
    {
        searchBar.searchBarStyle = UISearchBarStyleMinimal;
    }
    
    [self.tableView addSubview:searchBar];
    
    //Initialize the dataArray
    dataArray = [[NSMutableArray alloc] init];
    searchArray = [[NSMutableArray alloc] init];
    
    [self performSelector:@selector(addPois:) withObject:nil afterDelay:1];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** Añade las diez ubicaciones mas cercanas a tu posicion, se van acumulando hasta un total de 40 veces */
- (void)addPois:(id)sender
{
    if (loadingPois == NO)
    {
        loadingPois = YES;
        
        if (firstReloadDone == NO)
        {
            self.mapView.showsUserLocation = YES;
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
            firstReloadDone = YES;
        }
        
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        [locationManager startUpdatingLocation];
        CLLocation *location = [locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
        // NSLog(@"Lat: %@ Lon: %@", latitude, longitude);
        
        NSNumber *latitudeNumber = [NSNumber numberWithInteger:latitude.integerValue];
        NSNumber *longitudeNumber = [NSNumber numberWithInteger:longitude.integerValue];
        
        
        if ((((latitudeNumber.doubleValue + 90) - (oldLatitude.doubleValue + 90)) > 0.015) || (((latitudeNumber.doubleValue + 90) - (oldLatitude.doubleValue + 90)) < -0.015))
        {
            //NSLog(@"latitud Nueva: %f Latitud Vieja : %f", latitudeNumber.doubleValue, oldLatitude.doubleValue);
            [self clearMapAnnotations:nil];
        }
        
        if ((((longitudeNumber.doubleValue + 180) - (oldLongitude.doubleValue + 180)) > 0.015) || (((longitudeNumber.doubleValue + 180) - (oldLongitude.doubleValue + 180)) < -0.015))
        {
            //NSLog(@"longitud Nueva: %f longitud Vieja : %f", longitudeNumber.doubleValue, oldLongitude.doubleValue);
            [self clearMapAnnotations:nil];
        }
        
        oldLatitude = latitudeNumber;
        oldLongitude = longitudeNumber;
        
        if (latitude.integerValue == 0 && longitude.integerValue == 0)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Activar Localización", @"")
                                        message:NSLocalizedString(@"Activa los servicios de localización para Triporg y conoce las ubicaciones mas cercanas a tu posición.", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
            loadingPois = NO;
        }
        else
        {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [[TZTriporgManager sharedManager] nearPlacesWithLat:latitude lon:longitude start:[NSNumber numberWithInteger:(poisOnScreen * 10)] length:[NSNumber numberWithInteger:10] callback:^(id callback) {
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                if ([callback isKindOfClass:[NSArray class]])
                {
                    NSDictionary *ItemsArrayDict = [NSDictionary dictionaryWithObject:callback forKey:@"data"];
                    [dataArray addObject:ItemsArrayDict];
                    
                    [self.tableView reloadData];
                    
                    [self.mapView addAnnotations:callback];
                    
                    [searchArray addObjectsFromArray:callback];
                    
                    poisOnScreen++;
                    
                    instructionLabel.text = [NSString stringWithFormat:@"%d POIs", poisOnScreen * 10];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                                message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                      otherButtonTitles:nil] show];
                }
                
                loadingPois = NO;
                
                if (poisOnScreen == 40)
                {
                    self.navigationItem.rightBarButtonItem.enabled = NO;
                }
            }];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[TZTripEvent class]])
    {
        TZTripEvent *annotationEvent = annotation;
        
        MKPinAnnotationView *customPinview = [[MKPinAnnotationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:nil];
        customPinview.pinColor = MKPinAnnotationColorGreen;
        customPinview.animatesDrop = YES;
        customPinview.canShowCallout = YES;
        customPinview.enabled = YES;
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tag = annotationEvent.id.integerValue;
        [detailButton addTarget:self action:@selector(detailPressed:) forControlEvents:UIControlEventTouchDown];
        if (detailButton.tag != 0)
        {
            customPinview.rightCalloutAccessoryView = detailButton;
        }
        return customPinview;
    }
    else
    {
        return nil;
    }
}

/** Funcion que se ejecuta al presionar el boton detalle de la anotación del mapa y te lleva a la descripción de la ubicación */
- (void)detailPressed:(UIButton *)button
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    eventDetail = nil;
    eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripEventDetail"];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[TZTriporgManager sharedManager] getLocationWithId:[NSNumber numberWithInteger:button.tag] callback:^(TZEvent *event) {
        
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

/** Te lleva a la descripción de la ubicación */
- (void)goToTheDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:eventDetail animated:YES];
}

/** Cambia el tipo de mapa que se muestra */
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

/** Muestra la lista de Pois */
- (IBAction)showPoisList:(id)sender
{
    if (self.tableView.hidden == YES)
    {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionMoveIn;
        animation.subtype = kCATransitionFromTop;
        animation.duration = 0.36f;
        animation.delegate = self;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [self.tableView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
        
        self.tableView.hidden = NO;
        
        showListButton.tintColor = showListButton.tintColor = [UIColor grayColor];
    }
    else if (self.tableView.hidden == NO)
    {
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromBottom;
        animation.duration = 0.36f;
        animation.delegate = self;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [self.tableView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
        
        self.tableView.hidden = YES;
        
        showListButton.tintColor = showListButton.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_filteredEvents ? 1 : dataArray.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of rows it should expect should be based on the section
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    
    return (_filteredEvents ? _filteredEvents.count : [array count]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    
    TZTripEvent *tripEvent;
    tripEvent = _filteredEvents ? [_filteredEvents objectAtIndex:indexPath.row] : [array objectAtIndex:indexPath.row];
    cell.textLabel.text = tripEvent.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    eventDetail = nil;
    eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripEventDetail"];
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    TZTripEvent *EventActivity;
    EventActivity = _filteredEvents ? [_filteredEvents objectAtIndex:indexPath.row] : [array objectAtIndex:indexPath.row];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[TZTriporgManager sharedManager] getLocationWithId:EventActivity.id callback:^(TZEvent *event) {
        
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!searchText || searchText.length == 0)
    {
        [searchBar endEditing:YES];
        [searchBar resignFirstResponder];
        _filteredEvents = nil;
        [self.tableView reloadData];
        
        return;
    }
    
    if ([searchArray count] != 0)
    {
        _filteredEvents = [searchArray collect:^id(TZTripEvent *e) {
            BOOL match =
            [e.name.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound;
            return match ? e : nil;
        }];
    }
    
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    _filteredEvents = nil;
    searchBar.text = @"";
    [self.tableView reloadData];
}

- (void)clearMapAnnotations:(id)sender
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    dataArray = [[NSMutableArray alloc] init];
    poisOnScreen = 0;
    instructionLabel.text = [NSString stringWithFormat:@"%d POIs", poisOnScreen * 10];
}

@end
