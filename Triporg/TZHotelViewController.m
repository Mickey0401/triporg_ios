//
//  TZHotelViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 02/12/13.
//
//

#import "TZHotelViewController.h"
#import "TZTriporgManager.h"
#import "TZTripsTableController.h"
#import "MBProgressHUD.h"
#import "TZCreateTripController.h"
#import "UIColor+String.h"

@interface TZHotelViewController ()

@end

@implementation TZHotelViewController{
    CGPoint touchPoint;
    NSString *regionShow;
    NSString *regionBShow;
    NSNumber *latitude;
    NSNumber *longitude;
    NSUserDefaults *defaults;
}

@synthesize mapHotelView,searchBar;

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
    
    self.title = NSLocalizedString(@"Ubicar Hotel", @"");
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hecho", @"") style:UIBarButtonItemStyleDone target:self action:@selector(hotelDone:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancelar", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goToDestination:)];
    
    mapHotelView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 109, self.view.bounds.size.width, self.view.bounds.size.height - 65)];
    
    [self.view addSubview:mapHotelView];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 65, self.view.bounds.size.width, 44)];
    searchBar.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    searchBar.delegate = self;
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 109, self.mapHotelView.bounds.size.width, 30)];
    instructionLabel.text = NSLocalizedString(@"Utiliza el buscador o mantén pulsada la ubicación deseada en el mapa.", @"");
    instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    instructionLabel.textColor = [UIColor grayColor];
    instructionLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.numberOfLines = 0;
    [instructionLabel.layer setCornerRadius:7.0f];
    [instructionLabel.layer setMasksToBounds:YES];
    [self.view addSubview:instructionLabel];
    
    // iOS Version
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    if ([versioniOS hasPrefix:@"6."])
    {
        mapHotelView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
        instructionLabel.frame = CGRectMake(0, 44, self.mapHotelView.bounds.size.width, 30);
    }
    else
    {
        searchBar.searchBarStyle = UISearchBarStyleMinimal;
    }
    
    [self.view addSubview:searchBar];
    
    NSNumber *setLat = [defaults objectForKey:@"latitudCiudad"];
    NSNumber *setLon = [defaults objectForKey:@"longitudCiudad"];
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake([setLat doubleValue], [setLon doubleValue]);
    MKCoordinateRegion adjustedRegion = [mapHotelView regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 3400, 3400)];
    [mapHotelView setRegion:adjustedRegion animated:NO];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = adjustedRegion.center;
    annot.title = @"Hotel";
    
    [self.mapHotelView addAnnotation:annot];
    
    latitude = [NSNumber numberWithDouble:annot.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:annot.coordinate.longitude];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    [self.mapHotelView addGestureRecognizer:lpgr];
    
    regionShow = [defaults objectForKey:@"nombreCiudad"];
    regionBShow = [defaults objectForKey:@"nombrePais"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIView *helpView = [[UIView alloc] initWithFrame:CGRectMake(768, 0, 256, 768)];
        helpView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        helpView.layer.borderWidth = 0.5f;
        helpView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [self.view addSubview:helpView];
        
        UIView *roundView = [[UIView alloc] initWithFrame:CGRectMake(10, 117, 256 - 20, 768 - 170)];
        roundView.backgroundColor = [UIColor whiteColor];
        roundView.layer.borderWidth = 0.5f;
        roundView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [roundView.layer setCornerRadius:6.0f];
        [roundView.layer setMasksToBounds:YES];
        [helpView addSubview:roundView];
        
        UILabel *titleHelpLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 256 - 60, 100)];
        titleHelpLabel.text = NSLocalizedString(@"¿Para qué ubicar mi Hotel?",@"");
        titleHelpLabel.textColor = [UIColor darkGrayColor];
        titleHelpLabel.backgroundColor = [UIColor clearColor];
        titleHelpLabel.numberOfLines = 0;
        titleHelpLabel.font = [UIFont systemFontOfSize:22];
        titleHelpLabel.textAlignment = NSTextAlignmentLeft;
        
        [roundView addSubview:titleHelpLabel];
        
        UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 256 - 60, 400 - 40)];
        helpLabel.textColor = [UIColor grayColor];
        helpLabel.backgroundColor = [UIColor clearColor];
        helpLabel.text = NSLocalizedString(@"Triporg comenzará y terminará cada jornada de viaje en el lugar donde vas a dormir.\nAdemás Triporg calcula la distancia entre tu alojamiento y las actividades ¡Optimiza tu agenda de viaje!", @"");
        helpLabel.font = [UIFont systemFontOfSize:19];
        helpLabel.numberOfLines = 0;
        helpLabel.textAlignment = NSTextAlignmentLeft;
        [roundView addSubview:helpLabel];
        
        UIImageView *helpImage = [[UIImageView alloc] initWithFrame:CGRectMake(77, 500, 80, 80)];
        helpImage.image = [UIImage imageNamed:@"sleep"];
        helpImage.backgroundColor = [UIColor clearColor];
        helpImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [roundView addSubview:helpImage];
        
        if ([versioniOS hasPrefix:@"6."])
        {
            CGRect frame = roundView.frame;
            frame.origin.y = 70;
            frame.origin.x = frame.origin.x + 10;
            roundView.frame = frame;
            
            frame = helpView.frame;
            frame.origin.x = frame.origin.x - 20;
            frame.size.width = frame.size.width + 20;
            helpView.backgroundColor = [UIColor colorWithString:@"#eeeeee"];
            helpView.frame = frame;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    mapHotelView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    mapHotelView.delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hotelDone:(id)sender
{
    if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                    message:NSLocalizedString(@"No puede crear un nuevo viaje sin conexión a internet.", @"No puede crear un nuevo viaje sin conexión a internet.")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                          otherButtonTitles:nil] show];
    }
    else
    {
        NSNumber *tripId = [defaults objectForKey:@"idViajeFinal"];
        
        [defaults removeObjectForKey:@"readyForResctriction"];
        [defaults synchronize];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
        hud.detailsLabelText = NSLocalizedString(@"Calculando el mejor itinerario", @"");
        
        [[TZTriporgManager sharedManager] createHotelWithId:tripId lat:latitude lon:longitude callback:^(id result) {
            [self performSelector:@selector(createFinalTrip:) withObject:nil];
        }];
    }
}

- (void)createFinalTrip:(id)sender
{
    NSNumber *tripId = [defaults objectForKey:@"idViajeFinal"];
    
    [[TZTriporgManager sharedManager] generateFinalTrip:tripId callback:^(id result) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kTZTripCreated object:nil];
        }];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *customPinview = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation reuseIdentifier:nil];
    customPinview.pinColor = MKPinAnnotationColorGreen;
    customPinview.animatesDrop = YES;
    customPinview.canShowCallout = YES;
    return customPinview;
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    [searchBar resignFirstResponder];
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    touchPoint = [gestureRecognizer locationInView:self.mapHotelView];
    
    [self.mapHotelView removeAnnotations:[self.mapHotelView annotations]];
    
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapHotelView convertPoint:touchPoint toCoordinateFromView:self.mapHotelView];
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    annot.title = @"Hotel";
    
    [self.mapHotelView addAnnotation:annot];
    
    latitude = [NSNumber numberWithDouble:annot.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:annot.coordinate.longitude];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    /*
     [searchBar resignFirstResponder];
     _filteredEvents = nil;
     searchBar.text = @"";
     [self.tableView reloadData];
     */
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@ %@ %@",theSearchBar.text, regionShow, regionBShow] completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.region.center.latitude;
        region.center.longitude = placemark.region.center.longitude;
        MKCoordinateSpan span;
        double radius = placemark.region.radius / 1000;
        
        span.latitudeDelta = radius / 112.0;
        
        region.span = span;
        
        if ((region.center.latitude >= -90) && (region.center.latitude <= 90) && (region.center.longitude >= -180) && (region.center.longitude <= 180)&& (region.center.longitude != -180.00000000))
        {
            @try {
                [mapHotelView setRegion:[mapHotelView regionThatFits:region] animated:NO];
            }
            @catch (NSException *exception) {
                
            }
        }
        
        [self.mapHotelView removeAnnotations:[self.mapHotelView annotations]];
        
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.coordinate = region.center;
        annot.title = @"Hotel";
        
        latitude = [NSNumber numberWithDouble:annot.coordinate.latitude];
        longitude = [NSNumber numberWithDouble:annot.coordinate.longitude];
        
        [self.mapHotelView addAnnotation:annot];
    }];
}

- (void)goToDestination:(id)sender
{
    [defaults removeObjectForKey:@"readyForResctriction"];
    [defaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
