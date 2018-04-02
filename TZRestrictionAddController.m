//
//  TZRestrictionViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 03/09/13.
//
//

#import "TZRestrictionAddController.h"
#import "TZTripEvent.h"
#import "TZTriporgManager.h"
#import "TZEvent.h"
#import "TZCreateTripController.h"
#import "TZTripsTableController.h"
#import "MBProgressHUD.h"
#import "TZTrip.h"
#import "UIImage+Additions.h"
#import "UIColor+String.h"
#import <QuartzCore/QuartzCore.h>


@interface TZRestrictionAddController () {
    NSDictionary *paramsCita;
    NSString *regionShow;
    NSString *regionBShow;
    NSNumber *cityShow;
    NSNumber *tripId;
    CGPoint touchPoint;
    NSString *nombreCitas;
    NSString *nombreDireccion;
    NSNumber *latitude;
    NSNumber *longitude;
    NSDate *start;
    NSDate *end;
    NSDate *fechaReferenciaInicio;
    NSDate *fechaReferenciaFin;
    NSDateFormatter *firstDateFormatter;
    NSDateFormatter *dateFormatter;
    NSUserDefaults *defaults;
    NSString *versioniOS;
    NSInteger contadorCitas;
    UITextField *ipadNameText;
    UITextField *ipadStartText;
    UITextField *ipadEndText;
}

@end

@implementation TZRestrictionAddController

@synthesize mapRestrictView, searcher;

@synthesize editEndDate = _editEndDate;
@synthesize editStartDate = _editStartDate;
@synthesize nombreCita = _nombreCita;
@synthesize labelName,labelStart,labelEnd, restrictionNumber;


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
	
    self.title = NSLocalizedString(@"Nueva Cita", @"");
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    // iOS Version
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    searcher.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        searcher.searchBarStyle = UISearchBarStyleMinimal;
    }
    
    labelName.text = NSLocalizedString(@"Nombre", @"");
    labelStart.text = NSLocalizedString(@"Llegada", @"");
    labelEnd.text = NSLocalizedString(@"Salida", @"");
    
    mapRestrictView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 236, self.view.bounds.size.width, self.view.bounds.size.height -236)];
    
    [self.view addSubview:mapRestrictView];
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 236, self.mapRestrictView.bounds.size.width, 30)];
    instructionLabel.text = NSLocalizedString(@"Utiliza el buscador o mantén pulsada la ubicación deseada en el mapa. Procesar citas requiere tiempo.", @"");
    instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    instructionLabel.textColor = [UIColor grayColor];
    instructionLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.numberOfLines = 0;
    [instructionLabel.layer setCornerRadius:7.0f];
    [instructionLabel.layer setMasksToBounds:YES];
    [self.view addSubview:instructionLabel];
    
    UIImageView *SeparatorView = [[UIImageView alloc] init];
    UIImageView *SeparatorTwoView = [[UIImageView alloc] init];
    UIImageView *SeparatorThreeView = [[UIImageView alloc] init];
    
    UIColor *separatorColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"CellHeaderBackground"] tintImageWithColor:[UIColor lightGrayColor]]];
    SeparatorView.backgroundColor = separatorColor;
    SeparatorTwoView.backgroundColor = separatorColor;
    SeparatorThreeView.backgroundColor = separatorColor;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        CGFloat viewWidth = self.view.bounds.size.width;
        
        SeparatorView.frame = CGRectMake(20, 107, viewWidth - 20, 1);
        SeparatorTwoView.frame = CGRectMake(20, 149, viewWidth - 20, 1);
        SeparatorThreeView.frame = CGRectMake(20, 191, viewWidth - 20, 1);
        
        [_nombreCita removeFromSuperview];
        _nombreCita = nil;
        
        _nombreCita = [[UITextField alloc] initWithFrame:CGRectMake(97, 77, 620, 25)];
        _nombreCita.textColor = [UIColor grayColor];
        _nombreCita.backgroundColor = [UIColor clearColor];
        _nombreCita.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_nombreCita];
        
        [_editStartDate removeFromSuperview];
        _editStartDate = nil;
        
        _editStartDate = [[UITextField alloc] initWithFrame:CGRectMake(97, 121, 620, 25)];
        _editStartDate.textColor = [UIColor grayColor];
        _editStartDate.backgroundColor = [UIColor clearColor];
        _editStartDate.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_editStartDate];
        
        [_editEndDate removeFromSuperview];
        _editEndDate = nil;
        
        _editEndDate = [[UITextField alloc] initWithFrame:CGRectMake(97, 161, 620, 26)];
        _editEndDate.textColor = [UIColor grayColor];
        _editEndDate.backgroundColor = [UIColor clearColor];
        _editEndDate.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_editEndDate];
        
        [searcher removeFromSuperview];
        searcher = nil;
        
        searcher = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 192, 768, 44)];
        searcher.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
        searcher.delegate = self;
        [self.view addSubview:searcher];
        
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
        titleHelpLabel.text = NSLocalizedString(@"¿Qué es una Cita?", @"");
        titleHelpLabel.textColor = [UIColor darkGrayColor];
        titleHelpLabel.backgroundColor = [UIColor clearColor];
        titleHelpLabel.numberOfLines = 0;
        titleHelpLabel.font = [UIFont systemFontOfSize:22];
        titleHelpLabel.textAlignment = NSTextAlignmentLeft;
        
        [roundView addSubview:titleHelpLabel];
        
        UILabel *helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 256 - 60, 400 - 40)];
        helpLabel.textColor = [UIColor grayColor];
        helpLabel.backgroundColor = [UIColor clearColor];
        helpLabel.text = NSLocalizedString(@"Es un momento para relajarte, quedar con amigos o tener una reunión de trabajo.\nTriporg organizará tu viaje en función de tus citas, evitando que otras actividades se solapen con ellas.\n¡Puedes colocar tantas citas como desees! Basta con decir a Triporg dónde y cuándo.", @"");
        helpLabel.font = [UIFont systemFontOfSize:19];
        helpLabel.numberOfLines = 0;
        helpLabel.textAlignment = NSTextAlignmentLeft;
        [roundView addSubview:helpLabel];
        
        UIImageView *helpImage = [[UIImageView alloc] initWithFrame:CGRectMake(77, 500, 80, 80)];
        helpImage.image = [UIImage imageNamed:@"appointment-image"];
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
            
            frame = searcher.frame;
            frame.size.width = frame.size.width - 20;
            searcher.frame = frame;
        }
        else
        {
            searcher.searchBarStyle = UISearchBarStyleMinimal;
        }
        
    }
    else {
        SeparatorView.frame = CGRectMake(20, 107.5, 300, 0.5);
        SeparatorTwoView.frame = CGRectMake(20, 149.5, 300, 0.5);
        SeparatorThreeView.frame = CGRectMake(20, 191.5, 300, 0.5);
    }
    
    [self.view addSubview:SeparatorView];
    [self.view addSubview:SeparatorTwoView];
    [self.view addSubview:SeparatorThreeView];
    
    _nombreCita.delegate = self;
    _editStartDate.delegate = self;
    _editStartDate.delegate = self;
    
    contadorCitas = restrictionNumber.integerValue;
    
    _nombreCita.text = [NSString stringWithFormat:NSLocalizedString(@"Cita %d", @""), contadorCitas];
    _nombreCita.placeholder = NSLocalizedString(@"Nombre Cita", @"");
    
    tripId = [defaults objectForKey:@"idViajeFinal"];
    
    regionShow = [defaults objectForKey:@"nombreCiudad"];
    regionBShow = [defaults objectForKey:@"nombrePais"];
    cityShow = [defaults objectForKey:@"idCiudad"];
    
    start = [defaults objectForKey:@"readyForResctriction"];
    
    if (start == nil)
        start = [defaults objectForKey:@"fechaInicioViaje"];
    
    fechaReferenciaInicio = [defaults objectForKey:@"fechaInicioViaje"];
    fechaReferenciaFin = [defaults objectForKey:@"fechaFinalViaje"];
    
    end = [start dateByAddingTimeInterval:10*60];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDoubleTapped:)];
    tapGR.numberOfTapsRequired = 2;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85];
    
    [datePicker addGestureRecognizer:tapGR];
    
    [datePicker setDate:start];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [_editStartDate setInputView:datePicker];
    
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [_editEndDate setInputView:datePicker];
    
    firstDateFormatter = nil;
    
    if (!firstDateFormatter) {
        firstDateFormatter = [[NSDateFormatter alloc] init];
        firstDateFormatter.dateFormat = @"dd-MM HH:mm";
    }
    
    dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    _editStartDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:start]];
    _editEndDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:end]];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    [self.mapRestrictView addGestureRecognizer:lpgr];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hecho", @"") style:UIBarButtonItemStyleDone target:self action:@selector(createRestriction:)];
    
    NSNumber *setLat = [defaults objectForKey:@"latitudCiudad"];
    NSNumber *setLon = [defaults objectForKey:@"longitudCiudad"];
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake([setLat doubleValue], [setLon doubleValue]);
    MKCoordinateRegion adjustedRegion = [mapRestrictView regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 3400, 3400)];
    [mapRestrictView setRegion:adjustedRegion animated:NO];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = adjustedRegion.center;
    annot.title = _nombreCita.text;
    
    [self.mapRestrictView addAnnotation:annot];
    
    latitude = [NSNumber numberWithDouble:annot.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:annot.coordinate.longitude];
    
    nombreCitas = _nombreCita.text;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    mapRestrictView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    mapRestrictView.delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                [mapRestrictView setRegion:[mapRestrictView regionThatFits:region] animated:NO];
            }
            @catch (NSException *exception) {
                
            }
        }
        
        [self.mapRestrictView removeAnnotations:[self.mapRestrictView annotations]];
        
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.coordinate = region.center;
        
        annot.title = _nombreCita.text;
        
        latitude = [NSNumber numberWithDouble:annot.coordinate.latitude];
        longitude = [NSNumber numberWithDouble:annot.coordinate.longitude];
        
        [self.mapRestrictView addAnnotation:annot];
        
    }];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    [searcher resignFirstResponder];
    [_editEndDate resignFirstResponder];
    [_editStartDate resignFirstResponder];
    [_nombreCita resignFirstResponder];
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    touchPoint = [gestureRecognizer locationInView:self.mapRestrictView];
    
    [self.mapRestrictView removeAnnotations:[self.mapRestrictView annotations]];
    
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapRestrictView convertPoint:touchPoint toCoordinateFromView:self.mapRestrictView];
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    annot.title = _nombreCita.text;
    
    [self.mapRestrictView addAnnotation:annot];
    
    latitude = [NSNumber numberWithDouble:annot.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:annot.coordinate.longitude];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation
{
    MKPinAnnotationView *customPinview = [[MKPinAnnotationView alloc]
                                          initWithAnnotation:annotation reuseIdentifier:nil];
    customPinview.pinColor = MKPinAnnotationColorGreen;
    customPinview.animatesDrop = YES;
    customPinview.canShowCallout = YES;
    return customPinview;
}

- (void)createRestriction:(id)sender
{
    [self.view endEditing:YES];
    
    if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                    message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                          otherButtonTitles:nil] show];
    }
    else {
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.labelText = NSLocalizedString(@"Incluyendo Cita",@"");
        HUD.detailsLabelText = NSLocalizedString(@"Incluyendo cita en su viaje, el proceso puede tardar unos minutos.",@"");
        
        [HUD show:YES];
        
        nombreCitas= _nombreCita.text;
        
        if (nombreCitas.length == 0) {
            nombreCitas= [NSString stringWithFormat:@"Cita %d", contadorCitas];
        }
        
        contadorCitas++;
        
        CLGeocoder *ceo = [[CLGeocoder alloc] init];
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        
        [ceo reverseGeocodeLocation: loc completionHandler:
         ^(NSArray *placemarks, NSError *error) {
             
             if (!error) {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 
                 nombreDireccion = placemark.name;
             }
             else {
                 nombreDireccion = @" ";
             }
             
             paramsCita = [NSDictionary dictionaryWithObjectsAndKeys:
                           nombreCitas, @"name",
                           [dateFormatter stringFromDate:start], @"start",
                           [dateFormatter stringFromDate:end], @"end",
                           latitude, @"lat",
                           longitude, @"lon",
                           cityShow, @"city_id",
                           tripId, @"trip_id",
                           nombreDireccion, @"address", nil];
             
             [[TZTriporgManager sharedManager] createRestrictionWithData:paramsCita callback:^(id result) {
                 [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                 
                 _nombreCita.text = [NSString stringWithFormat:NSLocalizedString(@"Cita %d", @""), contadorCitas];
                 
                 start = [start dateByAddingTimeInterval:60*60];
                 end = [start dateByAddingTimeInterval:10*60];
                 
                 [defaults setObject:start forKey:@"readyForResctriction"];
                 [defaults synchronize];
                 
                 _editStartDate.text = [NSString stringWithFormat:@"%@", [firstDateFormatter stringFromDate:start]];
                 _editEndDate.text = [NSString stringWithFormat:@"%@", [firstDateFormatter stringFromDate:end]];
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }];
             
         }];
    }
}

- (void)updateTextField:(id)sender
{
    firstDateFormatter = nil;
    if (!firstDateFormatter) {
        firstDateFormatter = [[NSDateFormatter alloc] init];
        firstDateFormatter.dateFormat = @"dd-MM HH:mm";
    }
    
    if ([_editStartDate isFirstResponder]) {
        UIDatePicker *picker = (UIDatePicker*)_editStartDate.inputView;
        _editStartDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:picker.date]];
        start = picker.date;
        if ([start compare:fechaReferenciaInicio] == NSOrderedAscending)
        {
            start = fechaReferenciaInicio;
            _editStartDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:start]];
            [picker setDate:start];
        }
        
        if ([start compare:fechaReferenciaFin] == NSOrderedDescending)
        {
            start = [end dateByAddingTimeInterval:-10*60];
            _editStartDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:start]];
            [picker setDate:start];
        }
        
        if ([start compare:end] == NSOrderedDescending)
        {
            end = [start dateByAddingTimeInterval:10*60];
            _editEndDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:end]];
        }
        
    }
    if ([_editEndDate isFirstResponder]) {
        UIDatePicker *picker = (UIDatePicker*)_editEndDate.inputView;
        _editEndDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:picker.date]];
        end = picker.date;
        if ([end compare:fechaReferenciaFin] == NSOrderedDescending)
        {
            end = [start dateByAddingTimeInterval:10*60];
            _editEndDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:end]];
            [picker setDate:end];
        }
        
        if ([end compare:fechaReferenciaInicio] == NSOrderedAscending)
        {
            end = [start dateByAddingTimeInterval:10*60];
            _editEndDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:end]];
            [picker setDate:end];
        }
        
        if ([end compare:start] == NSOrderedAscending)
        {
            start = [end dateByAddingTimeInterval:-10*60];
            _editStartDate.text = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:start]];
        }
    }
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
    [searchBar resignFirstResponder];
}

- (void)viewDoubleTapped:(UITapGestureRecognizer *)tapGR
{
    [self.view endEditing:YES];
}


@end
