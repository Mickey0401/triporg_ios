//
//  TZTripDetailViewController.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZiPadListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "MBProgressHUD.h"
#import "NSDate+Utilities.h"
#import "NSDate+Helper.h"
#import "UIColor+String.h"
#import "UIImage+Additions.h"
#import "TZTripEventDetailController.h"
#import "TZTriporgManager.h"
#import "TZTrip.h"
#import "TZUser.h"
#import "TZTripEvent.h"
#import "TZEvent.h"
#import "TZTripEventCell.h"
#import "TZTripEventHeader.h"
#import "Reachability.h"
#import "NSArray+Additions.h"
#import "TZTripMapController.h"
#import "WebImageOperations.h"
#import "TZCityInfoController.h"
#import "UIScrollView+TwitterCover.h"
#import "FXLabel.h"
#import "ZKRevealingTableViewCell.h"
#import "TZCityiPadViewController.h"
#import "TZiPadMapViewController.h"

#define ZOOM_STEP 1.5

static TZTripEventDetailController *eventDetail = nil;
static TZCityInfoController *cityDetail = nil;

@interface TZiPadListViewController () {
    NSString *versioniOS;
    UIView *topView;
    FXLabel *titleLabel;
    FXLabel *dateLabel;
    UIButton *cityButton;
    UIView *saveNavigationView;
    UIView *BlurView;
    NSArray *mapClickedEvents;
    UIScrollView *scrollView;
    UIImageView *mapImageView;
    UITapGestureRecognizer *doubleTap;
    UITapGestureRecognizer *twoFingerTap;
    NSInteger zoom;
    UILabel *mapDayLabel;
    NSDate *memorizerDate;
}

@end


@implementation TZiPadListViewController

@synthesize trip = _trip;
@synthesize editing = _editing;
@synthesize searchBar = _searchBar;
@synthesize tableView;
@synthesize mapControl;
@synthesize containerView;


- (id)initWithTopView:(UIView*)view
{
    self = [super init];
    if (self) {
        topView = view;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Viaje", @"");
    
    mapControl.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    mapControl.alpha = 0.9;
    
    zoom = 0;
    
    if (!_trip.imageFinal)
    {
        [self.tableView addTwitterCoverWithImage:[[UIImage imageNamed:@"defaultInfoGrande"] tintImageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]] withTopView:topView];
    }
    else
    {
        [self.tableView addTwitterCoverWithImage:[[UIImage imageWithData:_trip.imageFinal] tintImageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]] withTopView:topView];
    }
    
    //This tableHeaderView plays the placeholder role here.
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, CHTwitterCoverViewHeight + topView.bounds.size.height)];
    
    titleLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, 10, self.tableView.bounds.size.width - 20, 30)];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeZero;
    titleLabel.shadowBlur = 12.0f;
    
    if (_trip.city.length == 0)
        titleLabel.text = _trip.trip_name;
    else
        titleLabel.text = _trip.city;
    
    [self.tableView addSubview:titleLabel];
    
    dateLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, 40, self.tableView.bounds.size.width - 20, 40)];
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.numberOfLines = 2;
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Llegada: %@ %@\nSalida: %@ %@", @"") ,
                      [_trip.start stringWithFormat:@"dd/MM/yyyy"],
                      [_trip.start stringWithFormat:@"HH:mm"],
                      [_trip.end stringWithFormat:@"dd/MM/yyyy"],
                      [_trip.end stringWithFormat:@"HH:mm"]];
    
    dateLabel.shadowColor = [UIColor blackColor];
    dateLabel.shadowOffset = CGSizeZero;
    dateLabel.shadowBlur = 12.0f;
    
    [self.tableView addSubview:dateLabel];
    
    cityButton = [[UIButton alloc] init];
    cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cityButton.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 80);
    cityButton.backgroundColor = [UIColor clearColor];
    
    if (!_trip.mapCache)
    {
        [cityButton addTarget:self action:@selector(cityPush:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [cityButton addTarget:self action:@selector(cityPushWithCache:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.tableView addSubview:cityButton];
    
    // iOS Version
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        self.tableView.backgroundColor = [UIColor colorWithString:@"#eeeeee"];
    }
    else
    {
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        saveNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, -70, 1024, 70)];
        saveNavigationView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.view addSubview:saveNavigationView];
    }
    
    // Configuracion de barButtons
    UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    
    UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareMyTrip:)];
    
    if (_trip.public_url.length > 0)
    {
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:editBarButton, shareBarButton, nil];
    }
    else
    {
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:editBarButton, nil];
    }
    
    [self performSelector:@selector(reloadContent:) withObject:nil afterDelay:0.5];
    
    mapClickedEvents = [[NSArray alloc] init];
    
    NSArray *eventsArray;
    
    if (_eventsByDays.count == 0)
    {
        eventsArray = [[NSArray alloc] init];
    }
    else
    {
        eventsArray = [_eventsByDays objectAtIndex:0];
    }
    
    if (!_trip.mapCache)
    {
        mapClickedEvents = nil;
        
        mapClickedEvents = eventsArray;
        
        CGFloat maxLat = [eventsArray maxWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
        CGFloat minLat = [eventsArray minWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
        CGFloat maxLng = [eventsArray maxWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
        CGFloat minLng = [eventsArray minWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
        
        self.mapView.region = (MKCoordinateRegion) {
            .center = {
                .latitude = (maxLat + minLat) / 2.0f,
                .longitude = (maxLng + minLng) / 2.0f
            },
            .span = {
                .latitudeDelta = ((maxLat - minLat) * 1.5),
                .longitudeDelta = ((maxLng - minLng) * 1.5)
            }
        };
        
        [self.mapView addAnnotations:eventsArray];
        
        [self.mapView reloadInputViews];
        
        mapDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(237 , 10,  250, 20)];
        mapDayLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
        mapDayLabel.textAlignment = NSTextAlignmentCenter;
        mapDayLabel.textColor = [UIColor grayColor];
        [mapDayLabel.layer setCornerRadius:6.0f];
        [mapDayLabel.layer setMasksToBounds:YES];
        
        TZTripEvent *tripEventOne;
        
        if (eventsArray.count == 0)
        {
            
        }
        else
        {
            tripEventOne = [eventsArray objectAtIndex:0];
        }
        
        NSDate *date = tripEventOne.start;
        
        mapDayLabel.text = [date stringWithFormat:@"EEEE, d LLLL, YYYY"];
        memorizerDate = date;
        
        [self.mapView addSubview:mapDayLabel];
    }
    else
    {
        CGRect mapFrame = self.mapView.frame;
        
        mapControl.hidden = YES;
        mapImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *imageForMap = [UIImage imageWithData:_trip.mapCache];
        mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, imageForMap.size.width, imageForMap.size.height)];
        mapImageView.image = imageForMap;
        mapImageView.userInteractionEnabled = YES;
        mapImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, mapFrame.size.width, mapFrame.size.height - 64)];
        scrollView.backgroundColor = [UIColor blackColor];
        
        [scrollView setContentSize:CGSizeMake(mapImageView.frame.size.width, mapImageView.frame.size.height)];
        
        scrollView.bouncesZoom = YES;
        scrollView.delegate = self;
        scrollView.clipsToBounds = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        
        CGFloat minimumScale = [scrollView frame].size.width / [mapImageView frame].size.width;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = minimumScale;
        scrollView.zoomScale = minimumScale;
        
        doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
        
        [doubleTap setNumberOfTapsRequired:2];
        [twoFingerTap setNumberOfTouchesRequired:2];
        
        [mapImageView addGestureRecognizer:doubleTap];
        [mapImageView addGestureRecognizer:twoFingerTap];
        
        [self.mapView addSubview:scrollView];
        [scrollView addSubview:mapImageView];
        
        [self centerScrollViewContents];
    }
    
    containerView.layer.borderWidth = 1.0f;
    containerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.mapView.layer.borderWidth = 1.0f;
    self.mapView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UIButton *buttonExpand = [[UIButton alloc] initWithFrame:CGRectMake(704 - 60, 10, 50, 50)];
    buttonExpand.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    buttonExpand.alpha = 0.9;
    [buttonExpand.layer setCornerRadius:7.0f];
    [buttonExpand.layer setMasksToBounds:YES];
    [buttonExpand setImage:[[UIImage imageNamed:@"maximize"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]] forState:UIControlStateNormal];
    [buttonExpand setImage:[[UIImage imageNamed:@"minimize"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]] forState:UIControlStateHighlighted];
    [buttonExpand addTarget:self action:@selector(expansion:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mapView addSubview:buttonExpand];
    
    if ([TZTriporgManager sharedManager].currentUser.isAutomatic == [NSNumber numberWithInteger:1])
    {
        [self callTheRegisterWindow:nil];
    }
}

- (void)expansion:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
    
    TZiPadMapViewController *iPadMapController = [storyboard instantiateViewControllerWithIdentifier:@"iPadMap"];
    iPadMapController.title = NSLocalizedString(@"Mapa", @"");
    
    if (!_trip.mapCache)
    {
        iPadMapController.tripEvents = mapClickedEvents;
        iPadMapController.cityId = _trip.city_id;
        iPadMapController.mapTypeMemorizer = mapControl.selectedSegmentIndex;
    }
    else
    {
        iPadMapController.trip = _trip;
    }
    
    [self.navigationController pushViewController:iPadMapController animated:YES];
}

- (void)reloadContent:(id)sender
{
    
    if ( _trip.events == nil)
    {
        [self performSelector:@selector(reloadContent:) withObject:nil afterDelay:0.5];
    }
    else
    {
        [self.tableView reloadData];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
    {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    // iOS Version
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        self.navigationController.navigationBar.translucent = YES;
    }
    
}

- (void)dealloc
{
    [self.tableView removeTwitterCoverView];
}

- (void)setTrip:(TZTrip *)trip
{
    _trip = trip;
    
    // Group events by days
    NSMutableArray *days = [NSMutableArray array];
    
    NSString *currentDay;
    NSMutableArray *eventsOfDay;
    
    NSInteger enumerador = 0;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    for (TZTripEvent *event in trip.events) {
        if ([[dateFormatter stringFromDate:event.start] isEqualToString:currentDay] == NO) {
            currentDay = [dateFormatter stringFromDate:event.start];
            enumerador = 0;
            eventsOfDay = [NSMutableArray array];
            [days addObject:eventsOfDay];
        }
        
        enumerador++;
        event.Indice = [NSNumber numberWithInteger:enumerador];
        [eventsOfDay addObject:event];
    }
    
    _eventsByDays = days;
    
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    if (!_editing) {
        
        UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
        
        UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareMyTrip:)];
        
        if (_trip.public_url.length > 0)
        {
            self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:editBarButton, shareBarButton, nil];
        }
        else
        {
            self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:editBarButton, nil];
        }
        
        if ([versioniOS hasPrefix:@"6."])
        {
            
        }
        else
        {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
        
    }
    else
    {
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hecho", @"") style:UIBarButtonItemStyleDone target:self action:@selector(editPressed:)];
        
        self.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:doneBarButton, nil];
        
        if ([versioniOS hasPrefix:@"6."])
        {
            
        }
        else
        {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

- (void)editPressed:(id)sender
{
    self.editing = !_editing;
    
    if (_editing)
    {
        _tripHasChange = NO;
        
        if (_allEvents)
        {
            [self.tableView reloadData];
            self.title = NSLocalizedString(@"Editar", @"");
            
            UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, self.tableView.bounds.size.width, 44)];
            searchBar.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
            searchBar.delegate = self;
            searchBar.layer.borderWidth = 0.5f;
            searchBar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            
            if ([versioniOS hasPrefix:@"6."])
            {
                self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
            }
            else
            {
                searchBar.searchBarStyle = UISearchBarStyleMinimal;
                self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
                searchBar.backgroundColor = [UIColor whiteColor];
            }
            
            [self.tableView addSubview:searchBar];
            _searchBar = searchBar;
            
            [self.tableView removeTwitterCoverView];
            self.tableView.tableHeaderView = nil;
            [titleLabel removeFromSuperview];
            [dateLabel removeFromSuperview];
            [cityButton removeFromSuperview];
            
            BlurView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, self.mapView.bounds.size.width + 10, self.mapView.bounds.size.height)];
            BlurView.opaque = NO;
            BlurView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
            
            CATransition *animation = [CATransition animation];
            animation.type = kCATransitionFade;
            animation.subtype = kCATransitionFromLeft;
            animation.duration = 0.2f;
            animation.delegate = self;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            [self.mapView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
            
            [self.mapView addSubview:BlurView];
            
            mapControl.hidden = YES;
        }
        else
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.detailsLabelText = NSLocalizedString(@"Descargando las actividades disponibles", @"");
            hud.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
            [[TZTriporgManager sharedManager] editTripWithId:_trip.id callback:^(id resp) {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                if ([resp isKindOfClass:[NSError class]])
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info" , @"")
                                                message:[NSString stringWithFormat:NSLocalizedString(@"Se ha producido un error en la conexión", @""), [resp localizedDescription]]
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                      otherButtonTitles:nil] show];
                    self.editing = NO;
                    [self.tableView reloadData];
                }
                else
                {
                    _allEvents = resp;
                    self.editing = YES;
                    self.title = NSLocalizedString(@"Editar", @"");
                    [self.tableView reloadData];
                    
                    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -44, self.tableView.bounds.size.width, 44)];
                    searchBar.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
                    searchBar.layer.borderWidth = 0.5f;
                    searchBar.layer.borderColor = [[UIColor lightGrayColor] CGColor];
                    
                    searchBar.delegate = self;
                    if ([versioniOS hasPrefix:@"6."])
                    {
                        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
                    }
                    else
                    {
                        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
                        searchBar.searchBarStyle = UISearchBarStyleMinimal;
                        searchBar.backgroundColor = [UIColor whiteColor];
                    }
                    [self.tableView addSubview:searchBar];
                    _searchBar = searchBar;
                    
                    [self.tableView removeTwitterCoverView];
                    self.tableView.tableHeaderView = nil;
                    [titleLabel removeFromSuperview];
                    [dateLabel removeFromSuperview];
                    [cityButton removeFromSuperview];
                    
                    BlurView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.bounds.size.width, self.mapView.bounds.size.height)];
                    BlurView.opaque = NO;
                    BlurView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
                    
                    CATransition *animation = [CATransition animation];
                    animation.type = kCATransitionFade;
                    animation.subtype = kCATransitionFromLeft;
                    animation.duration = 0.2f;
                    animation.delegate = self;
                    animation.timingFunction = UIViewAnimationCurveEaseInOut;
                    [self.mapView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
                    
                    [self.mapView addSubview:BlurView];
                    
                    mapControl.hidden = YES;
                    
                    [self performSelector:@selector(animateMyRow:) withObject:nil afterDelay:0.2];
                    
                    [self performSelector:@selector(animateMySecondRow:) withObject:nil afterDelay:0.4];
                }
            }];
        }
        
    } else {
        // Done pressed
        if (_tripHasChange) {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [[TZTriporgManager sharedManager] recalculateTripWithId:_trip.id callback:^(TZTrip *trip) {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
                self.trip = trip;
                [self.tableView reloadData];
                
                if (!_trip.mapCache)
                {
                    NSArray *eventsArray = [_eventsByDays objectAtIndex:0];
                    
                    mapClickedEvents = nil;
                    
                    mapClickedEvents = eventsArray;
                    
                    CGFloat maxLat = [eventsArray maxWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
                    CGFloat minLat = [eventsArray minWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
                    CGFloat maxLng = [eventsArray maxWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
                    CGFloat minLng = [eventsArray minWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
                    
                    self.mapView.region = (MKCoordinateRegion) {
                        .center = {
                            .latitude = (maxLat + minLat) / 2.0f,
                            .longitude = (maxLng + minLng) / 2.0f
                        },
                        .span = {
                            .latitudeDelta = ((maxLat - minLat) * 1.5),
                            .longitudeDelta = ((maxLng - minLng) * 1.5)
                        }
                    };
                    
                    [self.mapView addAnnotations:eventsArray];
                    
                    [self.mapView reloadInputViews];
                    
                    mapDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(237 , 10,  250, 20)];
                    mapDayLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
                    mapDayLabel.textAlignment = NSTextAlignmentCenter;
                    mapDayLabel.textColor = [UIColor grayColor];
                    [mapDayLabel.layer setCornerRadius:6.0f];
                    [mapDayLabel.layer setMasksToBounds:YES];
                    
                    TZTripEvent *tripEventOne = [eventsArray objectAtIndex:0];
                    
                    NSDate *date = tripEventOne.start;
                    
                    mapDayLabel.text = [date stringWithFormat:@"EEEE, d LLLL, YYYY"];
                    memorizerDate = date;
                    
                    [scrollView removeFromSuperview];
                    
                    [self.mapView addSubview:mapDayLabel];
                    
                }
            }];
        }
        
        _filteredEvents = nil;
        _searchBar.text = @"";
        [_searchBar removeFromSuperview];
        
        CATransition *animationEdit = [CATransition animation];
        animationEdit.type = kCATransitionFade;
        animationEdit.subtype = kCATransitionFromLeft;
        animationEdit.duration = 0.2f;
        animationEdit.delegate = self;
        animationEdit.timingFunction = UIViewAnimationCurveEaseInOut;
        [self.mapView.layer addAnimation:animationEdit forKey:@"transitionViewAnimation"];
        
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionReveal;
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.36f;
        animation.delegate = self;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        [self.containerView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
        
        containerView.hidden = YES;
        
        if (!_trip.mapCache)
            mapControl.hidden = NO;
        
        [BlurView removeFromSuperview];
        
        NSArray *subviewsArray = [containerView subviews];
        
        for (NSInteger i = subviewsArray.count - 1; i >= 0; i--) {
            [((UIView*)[subviewsArray objectAtIndex:i]) removeFromSuperview];
        }
        
        [eventDetail removeFromParentViewController];
        [cityDetail removeFromParentViewController];
        
        if (!_trip.imageFinal) {
            [self.tableView addTwitterCoverWithImage:[[UIImage imageNamed:@"defaultInfoGrande"] tintImageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]] withTopView:topView];
        }
        else {
            [self.tableView addTwitterCoverWithImage:[[UIImage imageWithData:_trip.imageFinal] tintImageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]] withTopView:topView];
        }
        
        //This tableHeaderView plays the placeholder role here.
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, CHTwitterCoverViewHeight + topView.bounds.size.height)];
        
        titleLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, 10, self.tableView.bounds.size.width - 20, 30)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22]];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        if (_trip.city.length == 0)
            titleLabel.text = _trip.trip_name;
        else
            titleLabel.text = _trip.city;
        
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeZero;
        titleLabel.shadowBlur = 12.0f;
        
        [self.tableView addSubview:titleLabel];
        
        dateLabel = [[FXLabel alloc] initWithFrame:CGRectMake(10, 40, self.tableView.bounds.size.width - 20, 40)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.numberOfLines = 2;
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Llegada: %@ %@\nSalida: %@ %@", @"") ,
                          [_trip.start stringWithFormat:@"dd/MM/yyyy"],
                          [_trip.start stringWithFormat:@"HH:mm"],
                          [_trip.end stringWithFormat:@"dd/MM/yyyy"],
                          [_trip.end stringWithFormat:@"HH:mm"]];
        dateLabel.shadowColor = [UIColor blackColor];
        dateLabel.shadowOffset = CGSizeZero;
        dateLabel.shadowBlur = 12.0f;
        
        [self.tableView addSubview:dateLabel];
        
        cityButton = [[UIButton alloc] init];
        cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cityButton.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 80);
        cityButton.backgroundColor = [UIColor clearColor];
        
        if (!_trip.mapCache) {
            [cityButton addTarget:self action:@selector(cityPush:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [cityButton addTarget:self action:@selector(cityPushWithCache:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.tableView addSubview:cityButton];
        
        if ([versioniOS hasPrefix:@"6."])
        {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        else
        {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.title = NSLocalizedString(@"Viaje", @"");
    }
    
    [self.tableView reloadData];
}

- (void)shareMyTrip:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[TZTriporgManager sharedManager] shareTripWithId:_trip.id callback:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
        if ([result isKindOfClass:[NSError class]])
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                        message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
        }
        else
        {
            NSURL *tripUrl = [NSURL URLWithString:_trip.public_url];
            
            UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[tripUrl] applicationActivities:nil];
            
            self.popover = [[UIPopoverController alloc] initWithContentViewController:shareController];
            self.popover.delegate = self;
            [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _editing ? 1 : (_eventsByDays.count + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_editing) {
        return (_filteredEvents ? _filteredEvents.count : _allEvents.count);
    } else {
        
        return section == 0 ? 1 : [[_eventsByDays objectAtIndex:section - 1] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_editing) {
        if (indexPath.section > 0) {
            NSArray *dayItems = [_eventsByDays objectAtIndex:indexPath.section - 1];
            return dayItems.count == indexPath.row + 1 || _editing ? 60.0f : 80.0f;
        } else {
            return 0;
        }
        
    }
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_editing && indexPath.section == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Header"];
        
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Header"];
        }
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    TZTripEventCell *cell = (TZTripEventCell *) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[TZTripEventCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TZTripEvent *tripEvent;
    TZEvent *event;
    
    if (_editing)
    {
        event = _filteredEvents ? [_filteredEvents objectAtIndex:indexPath.row] : [_allEvents objectAtIndex:indexPath.row];
        
        cell.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Duración: %@", @"") , [[NSDate dateFromString:event.duration withFormat:@"HH:mm:ss"] stringWithFormat:@"HH:mm"]];
        cell.textLabel.text = event.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n ", event.name_location];
        cell.selectedIndex = [event.status integerValue];
        cell.separatorContainer.hidden = YES;
        
        if (event.cacheEventImage == nil)
        {
            cell.photoView.image = [UIImage imageNamed:@"defaultInfoGrande"];
            
            if (self.tableView.decelerating == NO && !event.cacheEventImage)
            {
                if ([event.image rangeOfString:@"default"].location == NSNotFound)
                {
                    [WebImageOperations processImageDataWithURLString:[event.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"] andBlock:^(NSData *imageData) {
                        
                        if (cell.photoView.image == [UIImage imageNamed:@"defaultInfoGrande"])
                        {
                            event.cacheEventImage = imageData;
                            cell.photoView.image = [UIImage imageWithData:event.cacheEventImage];
                        }
                    }];
                    
                }
                else
                {
                    
                }
            }
        }
        else
        {
            cell.photoView.image = [UIImage imageWithData:event.cacheEventImage];
        }
        
        cell.colorStripEdit.backgroundColor = [UIColor colorWithString:event.color];
        
        cell.colorStripEdit.hidden = NO;
        
        BOOL selected = NO;
        for (TZTripEvent *te in _trip.events)
        {
            if ([te.id isEqualToNumber:event.id])
            {
                selected = YES;
                break;
            }
        }
        cell.eventSelected = selected;
        
        cell.onIndexChanged = ^(NSInteger index) {
            _tripHasChange = YES;
            
            [[TZTriporgManager sharedManager] setEventStatus:index tripId:_trip.id eventId:event.id callback:^(id resp) {
                
                if ([resp isKindOfClass:[NSError class]])
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                message:[NSString stringWithFormat:@"%@", [resp localizedDescription]]
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                      otherButtonTitles:nil] show];
                }
                else
                {
                    event.status = [NSNumber numberWithInteger:index];
                }
                
            }];
        };
        
    }
    else
    {
        NSArray *dayItems = [_eventsByDays objectAtIndex:indexPath.section - 1];
        
        tripEvent = [dayItems objectAtIndex:indexPath.row];
        event = tripEvent.events;
        
        cell.eventSelected = NO;
        
        // arreglar problema de fecha
        NSDate *startDate = tripEvent.start;
        NSDate *citaDate = tripEvent.end;
        NSDate *interval = [NSDate dateFromString:tripEvent.duration withFormat:@"HH:mm:ss"];
        
        NSDate *zero = [NSDate dateFromString:@"00:00:00" withFormat:@"HH:mm:ss"];
        
        NSDate *endDate = [startDate dateByAddingTimeInterval:[interval timeIntervalSinceDate:zero]];
        
        NSString *distanceTimeString = [NSString stringWithFormat:NSLocalizedString(@"%@ minutos a píe", @""), @(tripEvent.distance_minutes.integerValue)];
        
        if (tripEvent.distance_meters.floatValue > 1000)
        {
            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
            [fmt setPositiveFormat:@"0.##"];
            NSString *kmConvertString = [fmt stringFromNumber:[NSNumber numberWithFloat:tripEvent.distance_meters.floatValue / 1000]];
            cell.separationLabel.text = [NSString stringWithFormat:@"%@ km - %@", kmConvertString, distanceTimeString];
        }
        else
        {
            cell.separationLabel.text = [NSString stringWithFormat:@"%d m - %@", tripEvent.distance_meters.integerValue, distanceTimeString];
        }
        
        cell.separatorContainer.hidden = NO;
        cell.detailTextLabel.text = tripEvent.name_location;
        
        cell.separatorContainer.hidden = indexPath.row == dayItems.count - 1;
        
        if ([tripEvent.id isEqualToNumber:[NSNumber numberWithInteger:0]])
        {
            cell.citaOn = YES;
            if ([tripEvent.color isEqualToString:@"#333333"])
            {
                cell.appointmentView.image = [[UIImage imageNamed:@"sleep"] tintImageWithColor:[UIColor colorWithString:@"#adccad"]];
                cell.timeLabel.text = [NSString stringWithFormat:@"%@",
                                       [startDate stringWithFormat:@"HH:mm"]];
                cell.hotelOn = YES;
            }
            else
            {
                cell.appointmentView.image = [[UIImage imageNamed:@"appointment-image"] tintImageWithColor:[UIColor colorWithString:@"#adccad"]];
                cell.timeLabel.text = [NSString stringWithFormat:@"%@-%@",
                                       [startDate stringWithFormat:@"HH:mm"],
                                       [citaDate stringWithFormat:@"HH:mm"]];
                cell.hotelOn = NO;
            }
        }
        else
        {
            cell.citaOn = NO;
            cell.hotelOn = NO;
            cell.timeLabel.text = [NSString stringWithFormat:@"%@-%@",
                                   [startDate stringWithFormat:@"HH:mm"],
                                   [endDate stringWithFormat:@"HH:mm"]];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", tripEvent.Indice, tripEvent.name];
        
        cell.photoView.image = [UIImage imageWithData:tripEvent.cacheImage];
    }
    
    if (_editing || indexPath.section != 0)
    {
        cell.detailTextLabel.numberOfLines = 0;
        
        if (_editing == NO)
        {
            cell.colorStripEdit.hidden = YES;
        }
        
        cell.editable = self.editing;
        cell.editing = self.editing;
        
        cell.colorStrip.backgroundColor = [UIColor colorWithString:tripEvent.color];
        
        if ([event.color isEqualToString:@"#00a7b7"])
        {
            cell.bevelView.image = [[UIImage imageNamed:@"Pattern"] tintImageWithColor:[UIColor colorWithString:@"#007A85"]];
        }
        else if ([event.color isEqualToString:@"#979797"])
        {
            cell.bevelView.image = [[UIImage imageNamed:@"Pattern"] tintImageWithColor:[UIColor colorWithString:@"#7D7D7D"]];
        }
        else if ([event.color isEqualToString:@"#e7494a"])
        {
            cell.bevelView.image = [[UIImage imageNamed:@"Pattern"] tintImageWithColor:[UIColor colorWithString:@"#E21D1D"]];
        }
        else if ([event.color isEqualToString:@"#56be23"])
        {
            cell.bevelView.image = [[UIImage imageNamed:@"Pattern"] tintImageWithColor:[UIColor colorWithString:@"#43931B"]];
        }
        else if ([event.color isEqualToString:@"#ffb200"])
        {
            cell.bevelView.image = [[UIImage imageNamed:@"Pattern"] tintImageWithColor:[UIColor colorWithString:@"#CC8F00"]];
        }
        else if ([event.color isEqualToString:@"#54a9ea"])
        {
            cell.bevelView.image = [[UIImage imageNamed:@"Pattern"] tintImageWithColor:[UIColor colorWithString:@"#2591E4"]];
        }
        else if ([event.color isEqualToString:@"#6b1b7e"])
        {
            cell.bevelView.image = [[UIImage imageNamed:@"Pattern"] tintImageWithColor:[UIColor colorWithString:@"#591669"]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _editing || section == 0 ? 0 : 37.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_editing || section == 0)
        return nil;
    
    TZTripEventHeader *header = [[TZTripEventHeader alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 37)];
    
    NSArray *eventsArray = [_eventsByDays objectAtIndex:section - 1];
    
    TZTripEvent *tripEvent = [eventsArray objectAtIndex:0];
    
    NSDate *date = tripEvent.start;
    
    header.textLabel.text = [date stringWithFormat:@"EEEE, d LLLL, YYYY"];
    
    header.showMapCallback = ^(TZTripEventHeader *header_) {
        
        BOOL blockAnimationMap = NO;
        
        if (containerView.hidden == NO)
        {
            CATransition *animation = [CATransition animation];
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromLeft;
            animation.duration = 0.36f;
            animation.delegate = self;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            [self.containerView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
            
            containerView.hidden = YES;
            
            blockAnimationMap = YES;
        }
        
        if (!_trip.mapCache)
        {
            mapClickedEvents = nil;
            
            mapClickedEvents = eventsArray;
            
            CGFloat maxLat = [eventsArray maxWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
            CGFloat minLat = [eventsArray minWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
            CGFloat maxLng = [eventsArray maxWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
            CGFloat minLng = [eventsArray minWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
            
            self.mapView.region = (MKCoordinateRegion) {
                .center = {
                    .latitude = (maxLat + minLat) / 2.0f,
                    .longitude = (maxLng + minLng) / 2.0f
                },
                .span = {
                    .latitudeDelta = ((maxLat - minLat) * 1.5),
                    .longitudeDelta = ((maxLng - minLng) * 1.5)
                }
            };
            
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            
            if ([[date stringWithFormat:@"EEEE, d LLLL, YYYY"] isEqualToString:mapDayLabel.text])
            {
                
            }
            else
            {
                if (blockAnimationMap == NO)
                {
                    CATransition *animation = [CATransition animation];
                    animation.type = kCATransitionPush;
                    
                    switch ([date compare:memorizerDate])
                    {
                        case NSOrderedAscending:
                            // dateOne is earlier in time than dateTwo
                            animation.subtype = kCATransitionFromBottom;
                            break;
                        case NSOrderedSame:
                            // The dates are the same
                            animation.subtype = kCATransitionFromTop;
                            break;
                        case NSOrderedDescending:
                            // dateOne is later in time than dateTwo
                            animation.subtype = kCATransitionFromTop;
                            break;
                    }
                    
                    animation.duration = 0.36f;
                    animation.delegate = self;
                    animation.timingFunction = UIViewAnimationCurveEaseInOut;
                    [self.mapView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
                }
            }
            
            [self.mapView addAnnotations:eventsArray];
            
            [self.mapView reloadInputViews];
            
            [mapDayLabel removeFromSuperview];
            mapDayLabel = nil;
            
            mapDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(237 , 10,  250, 20)];
            mapDayLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
            mapDayLabel.textAlignment = NSTextAlignmentCenter;
            mapDayLabel.textColor = [UIColor grayColor];
            [mapDayLabel.layer setCornerRadius:6.0f];
            [mapDayLabel.layer setMasksToBounds:YES];
            
            mapDayLabel.text = [date stringWithFormat:@"EEEE, d LLLL, YYYY"];
            memorizerDate = date;
            
            [self.mapView addSubview:mapDayLabel];
            
        }
        else
        {
            
        }
    };
    
    return header;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_editing && indexPath.section == 0) {
        
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
    
    TZEvent *Event = nil;
    
    if (_editing)
    {
        Event = [_filteredEvents ?: _allEvents objectAtIndex:indexPath.row];
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[TZTriporgManager sharedManager] getEventWithId:Event.id callback:^(TZEvent *event) {
            
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
                
                [eventDetail removeFromParentViewController];
                [cityDetail removeFromParentViewController];
                
                eventDetail = nil;
                eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"TableiPad"];
                
                eventDetail.type = TZTripItemTypeEvent;
                
                NSArray *subviewsArray = [containerView subviews];
                
                for (NSInteger i = subviewsArray.count - 1; i >= 0; i--) {
                    [((UIView*)[subviewsArray objectAtIndex:i]) removeFromSuperview];
                }
                
                eventDetail.eventShow = nil;
                eventDetail.eventShow = event;
                
                containerView.hidden = NO;
                
                CATransition *animation = [CATransition animation];
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromRight;
                animation.duration = 0.36f;
                animation.delegate = self;
                animation.timingFunction = UIViewAnimationCurveEaseInOut;
                [containerView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                [containerView addSubview:eventDetail.view];
                [self addChildViewController:eventDetail];
                
            }
            
        }];
        
    }
    else
    {
        if (indexPath.section >= 1)
        {
            Event = [[_eventsByDays objectAtIndex:indexPath.section - 1] objectAtIndex:indexPath.row];
            
            if ([Event.id isEqualToNumber:[NSNumber numberWithInteger:0]])
            {
                return;
            }
            
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [[TZTriporgManager sharedManager] getEventWithId:Event.id callback:^(TZEvent *event) {
                
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
                    [eventDetail removeFromParentViewController];
                    [cityDetail removeFromParentViewController];
                    
                    eventDetail = nil;
                    eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"TableiPad"];
                    
                    eventDetail.type = TZTripItemTypeEvent;
                    
                    NSArray *subviewsArray = [containerView subviews];
                    
                    for (NSInteger i = subviewsArray.count - 1; i >= 0; i--)
                    {
                        [((UIView*)[subviewsArray objectAtIndex:i]) removeFromSuperview];
                    }
                    
                    eventDetail.eventShow = nil;
                    eventDetail.eventShow = event;
                    
                    containerView.hidden = NO;
                    
                    CATransition *animation = [CATransition animation];
                    animation.type = kCATransitionMoveIn;
                    animation.subtype = kCATransitionFromRight;
                    animation.duration = 0.36f;
                    animation.delegate = self;
                    animation.timingFunction = UIViewAnimationCurveEaseInOut;
                    [containerView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
                    
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    
                    [containerView addSubview:eventDetail.view];
                    [self addChildViewController:eventDetail];
                }
            }];
        }
    }
}

- (void)goToTheEventDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:eventDetail animated:YES];
}

- (void)animateMyRow:(id)sender
{
    NSIndexPath *rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromRight;
    animation.duration = 0.36f;
    animation.delegate = self;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [[self.tableView cellForRowAtIndexPath:rowToReload].layer addAnimation:animation forKey:@"transitionViewAnimation"];
}

- (void)animateMySecondRow:(id)sender
{
    NSIndexPath *rowToReloadTwo = [NSIndexPath indexPathForRow:1 inSection:0];
    
    CATransition *animationTwo = [CATransition animation];
    animationTwo.type = kCATransitionMoveIn;
    animationTwo.subtype = kCATransitionFromRight;
    animationTwo.duration = 0.36f;
    animationTwo.delegate = self;
    animationTwo.timingFunction = UIViewAnimationCurveEaseInOut;
    [[self.tableView cellForRowAtIndexPath:rowToReloadTwo].layer addAnimation:animationTwo forKey:@"transitionViewAnimationSecond"];
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

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!searchText || searchText.length == 0)
    {
        //[self.tableView becomeFirstResponder];
        [searchBar endEditing:YES];
        [searchBar resignFirstResponder];
        _filteredEvents = nil;
        [self.tableView reloadData];
        
        return;
    }
    
    _filteredEvents = [_allEvents collect:^id(TZEvent *e) {
        BOOL match =
        [e.name.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound
        || [e.name_location.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound;
        //|| [e.tipo_actividad.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound;
        return match ? e : nil;
    }];
    [self.tableView reloadData];
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //[searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    _filteredEvents = nil;
    searchBar.text = @"";
    [self.tableView reloadData];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_editing)
        [self.tableView reloadData];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mapImageView;
}

//funcion que acerca la imagen al dar dos toques seguidos y aleja la siguiente vez
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


- (void)cityPush:(id)sender
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.labelText = NSLocalizedString(@"Descargando Datos",@"");
    
    [HUD show:YES];
    
    [[TZTriporgManager sharedManager] getCityInfoWithId:_trip.city_id callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSError class]])
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
            [eventDetail removeFromParentViewController];
            [cityDetail removeFromParentViewController];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
            
            cityDetail = nil;
            cityDetail = [storyboard instantiateViewControllerWithIdentifier:@"iPadCity"];
            
            NSArray *subviewsArray = [containerView subviews];
            
            for (NSInteger i = subviewsArray.count - 1; i >= 0; i--)
            {
                [((UIView*)[subviewsArray objectAtIndex:i]) removeFromSuperview];
            }
            
            TZCityWithDesc *event = resp;
            cityDetail.eventShow = event;
            
            containerView.hidden = NO;
            
            CATransition *animation = [CATransition animation];
            animation.type = kCATransitionMoveIn;
            animation.subtype = kCATransitionFromRight;
            animation.duration = 0.36f;
            animation.delegate = self;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            [containerView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            
            [containerView addSubview:cityDetail.view];
            [self addChildViewController:cityDetail];
        }
    }];
}

- (void)cityPushWithCache:(id)sender
{
    [[TZTriporgManager sharedManager] downloadCityInfoWithId:_trip.city_id callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSError class]])
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"")
                                                              message:NSLocalizedString(@"El viaje no se ha podido cargar. Conéctate a Internet y vuelve a intentarlo", @"" )
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                                    otherButtonTitles:nil];
            [message show];
        }
        else
        {
            [eventDetail removeFromParentViewController];
            [cityDetail removeFromParentViewController];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
            
            cityDetail = nil;
            cityDetail = [storyboard instantiateViewControllerWithIdentifier:@"iPadCity"];
            
            NSArray *subviewsArray = [containerView subviews];
            
            for (NSInteger i = subviewsArray.count - 1; i >= 0; i--)
            {
                [((UIView*)[subviewsArray objectAtIndex:i]) removeFromSuperview];
            }
            
            TZCityWithDesc *event = resp;
            cityDetail.eventShow = event;
            
            containerView.hidden = NO;
            
            CATransition *animation = [CATransition animation];
            animation.type = kCATransitionMoveIn;
            animation.subtype = kCATransitionFromRight;
            animation.duration = 0.36f;
            animation.delegate = self;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            [containerView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
            
            [containerView addSubview:cityDetail.view];
            [self addChildViewController:cityDetail];
        }
    }];
}

- (void)goToTheCityDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:cityDetail animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(TZTripEvent *)annotation
{
    if (![annotation isKindOfClass:[TZTripEvent class]])
    {
        return nil;
    }
    else
    {
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
        view.calloutOffset = CGPointMake(0, -23);
        view.centerOffset = CGPointMake(0, -23);
        
        UIImage *marker = [[UIImage imageNamed:@"MapMarker"] tintImageWithColor:[UIColor colorWithString:annotation.color]];
        
        view.enabled = YES;
        view.canShowCallout = YES;
        
        UIImageView *markerView = [[UIImageView alloc] initWithImage:marker];
        markerView.frame = CGRectMake(0, 0, 45, 45);
        markerView.center = view.center;
        [view addSubview:markerView];
        
        UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(-10, -13, 20, 20)];
        
        if (mapClickedEvents.count > 0)
        {
            number.text = [NSString stringWithFormat:@"%u", [mapClickedEvents indexOfObject:annotation] + 1];
        }
        else
        {
            number.text = [NSString stringWithFormat:@"%u", [_trip.events indexOfObject:annotation] + 1];
        }
        
        number.textAlignment = NSTextAlignmentCenter;
        number.backgroundColor = [UIColor clearColor];
        [view addSubview:number];
        
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tag = annotation.id.integerValue;
        [detailButton addTarget:self action:@selector(detailPressed:) forControlEvents:UIControlEventTouchDown];
        if (detailButton.tag != 0)
        {
            view.rightCalloutAccessoryView = detailButton;
        }
        
        markerView.layer.opacity = 1;
        
        return view;
    }
}

- (void)detailPressed:(UIButton *)button
{
    TZTripEvent *selectedEvent = nil;
    for (TZTripEvent *event in _trip.events)
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
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
        
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
                [eventDetail removeFromParentViewController];
                [cityDetail removeFromParentViewController];
                
                eventDetail = nil;
                eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"TableiPad"];
                
                eventDetail.type = TZTripItemTypeEvent;
                
                NSArray *subviewsArray = [containerView subviews];
                
                for (NSInteger i = subviewsArray.count - 1; i >= 0; i--)
                {
                    [((UIView*)[subviewsArray objectAtIndex:i]) removeFromSuperview];
                }
                
                eventDetail.eventShow = nil;
                eventDetail.eventShow = event;
                
                containerView.hidden = NO;
                
                CATransition *animation = [CATransition animation];
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromRight;
                animation.duration = 0.36f;
                animation.delegate = self;
                animation.timingFunction = UIViewAnimationCurveEaseInOut;
                [containerView.layer addAnimation:animation forKey:@"transitionViewAnimation"];
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                
                [containerView addSubview:eventDetail.view];
                [self addChildViewController:eventDetail];
            }
        }];
    }
}

- (void)goToTheDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:eventDetail animated:YES];
}

- (void)callTheRegisterWindow:(id)sender
{
    NSString *messageText;
    
    NSDate *currentDate = [NSDate date];
    NSDate *automaticUserEnterDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"automaticLoginDate"];
    
    // Tiempo que damos al "automaticUser" antes de expulsarlo. Por defecto 24 horas
    automaticUserEnterDate = [automaticUserEnterDate dateByAddingTimeInterval:24*60*60];
    
    if ([currentDate compare:automaticUserEnterDate] == NSOrderedDescending)
    {
        messageText = NSLocalizedString(@"El periodo de prueba de 24 horas ha finalizado. Regístrate ahora para conservar tus viajes y preferencias.", @"");
    }
    else
    {
        messageText = NSLocalizedString(@"Recuerda que el periodo para los usuarios de prueba es de 24 horas. Regístrate para conservar tus viajes y preferencias.", @"");
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Registrarse", @"")
                          message:messageText
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancelar", @"")
                          otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    alert.tag = 1;
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *passwordField = [alert textFieldAtIndex:0];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        passwordField.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    }
    
    passwordField.placeholder = @"Email";
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        
        if ([buttonTitle isEqualToString:NSLocalizedString(@"Ok", @"")])
        {
            NSString *email = [alertView textFieldAtIndex:0].text;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[TZTriporgManager sharedManager] validateEmail:email callback:^(id result) {
                
                if ([result isKindOfClass:[NSError class]])
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                                                    message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                          otherButtonTitles:nil];
                    alert.tag = 7;
                    [alert show];
                }
                else if ([result isEqualToString:@"true"])
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    [[TZTriporgManager sharedManager] registerAutomaticUserWithEmail:email callback:^(id resp) {
                        if ([result isKindOfClass:[NSError class]])
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                                                            message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                                                           delegate:self
                                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                                  otherButtonTitles:nil];
                            
                            alert.tag = 7;
                            [alert show];
                        }
                        else
                        {
                            if ([resp isKindOfClass:[NSString class]])
                            {
                                if ([resp isEqualToString:@"registerFailed"]) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                                                    message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                                                                   delegate:self
                                                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                                          otherButtonTitles:nil];
                                    
                                    alert.tag = 7;
                                    [alert show];
                                }
                            }
                            else
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Bienvenido", @"")
                                                                                message:[NSString stringWithFormat:NSLocalizedString(@"Tu usuario y contraseña se han enviado a: %@ \n Por favor consúltalos y vuelve a iniciar sesión.", @""), email]
                                                                               delegate:self
                                                                      cancelButtonTitle:NSLocalizedString(@"Desconectar", @"")
                                                                      otherButtonTitles:nil];
                                
                                alert.tag = 22;
                                [alert show];
                            }
                        }
                    }];
                }
                else if ([result isEqualToString:@"false"])
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"") message:NSLocalizedString(@"Introduce un email válido", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];
                    
                    alert.tag = 7;
                    [alert show];
                    
                }
            }];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"Cancelar", @"")])
        {
            [[TZTriporgManager sharedManager] expulseAutomaticUsers];
        }
    }
    else if (alertView.tag == 7)
    {
        [self callTheRegisterWindow:nil];
    }
    else if (alertView.tag == 22)
    {
        [[TZTriporgManager sharedManager] logout];
    }
}


@end
