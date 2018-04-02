//
//  TZCityiPadViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 24/03/14.
//
//

#import "TZCityiPadViewController.h"
#import "TZCityInfoController.h"
#import <QuartzCore/QuartzCore.h>
#import "TZTriporgManager.h"
#import "TZCityWithDesc.h"
#import "TZTripHeaderCell.h"
#import "TZWebDescriptionCell.h"
#import "TZTripEventHeader.h"
#import "UIImage+Additions.h"
#import "UIColor+String.h"
#import "TZCommentViewController.h"
#import "TZPhotoViewController.h"
#import "TZUbicationController.h"
#import "TZPois.h"
#import "TZService.h"

#define HTML_BODY   \
@"<!DOCTYPE html>\
<html>\
<head>\
<style>body { font-family: HelveticaNeue; width: %fpx; margin: 0; padding: 5px 10px; text-align: left; } footer {font-family: HelveticaNeue-UltraLight; display: block; color: gray; font-style: italic; font-size: 13px; text-align: right } .tipoActividad { font-family: HelveticaNeue-Light; font-style: italic; color: #93D31B; font-size: 14px; margin-bottom: 3px; } h3 { font-family: HelveticaNeue-Bold;  margin-bottom: 0; padding-bottom: 0; } </style>\
</head>\
<body>\
<div id=\"main\">\
<h3>%@</h3>\
<span class=\"tipoActividad\">%@</span>\
<article>%@</article>\
<div>\
</div>\
<footer>\
%@\
</footer>\
</div>\
</body>\
</html>"

static TZPhotoViewController *photoController;

@interface TZCityiPadViewController () {
    UIButton *mostrarBus;
    UIButton *mostrarRecomend;
    UIButton *mostrarFicha;
    UIButton *mostrarCompras;
    UIButton *mostrarMapaPois;
    TZWebDescriptionCell *descriptionCell;
    TZWebDescriptionCell *recomendationCell;
    TZWebDescriptionCell *busCell;
    TZWebDescriptionCell *TouristCell;
    TZWebDescriptionCell *shoppingCell;
    TZTripHeaderCell *headerCell;
    MKMapView *mapaDetalle;
    NSString *htmlStringSimple;
    NSString *emptyString;
    NSString *versioniOS;
    NSInteger interruptorInfo;
    CGFloat htmlWidth;
    CGFloat allViewSize;
    BOOL RecOrDesc;
    BOOL mapIsOn;
}

@end

@implementation TZCityiPadViewController

@synthesize eventShow = _eventShow;
@synthesize tableView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Ciudad", @"");
    
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    allViewSize = 704;
    htmlWidth = 704 - 20;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    mapIsOn = NO;
    RecOrDesc = NO;
    emptyString = @"";
    interruptorInfo = 0;
    _descriptionHeight = 200;
    _recomendationHeight = 200;
    _transportHeight = 200;
    _tourismHeight = 200;
    _shopHeight = 200;
    
    // Colocar un footer de tamaño 0 impide que se dibujen separator lines en las celdas vacias en iOS 7
    UIView *footer =
    [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    [self performSelector:@selector(firstReload:) withObject:nil];
    
    UIButton *buttonExpand = [[UIButton alloc] initWithFrame:CGRectMake(644, 10, 50, 50)];
    buttonExpand.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    buttonExpand.alpha = 0.9;
    [buttonExpand.layer setCornerRadius:7.0f];
    [buttonExpand.layer setMasksToBounds:YES];
    [buttonExpand setImage:[[UIImage imageNamed:@"maximize"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]] forState:UIControlStateNormal];
    [buttonExpand setImage:[[UIImage imageNamed:@"minimize"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]] forState:UIControlStateHighlighted];
    [buttonExpand addTarget:self action:@selector(expansion:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:buttonExpand];
    
}

- (void)expansion:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    
    TZCityInfoController *cityDetail = [storyboard instantiateViewControllerWithIdentifier:@"cityInfo"];
    
    cityDetail.eventShow = _eventShow;
    
    [self.navigationController pushViewController:cityDetail animated:YES];
}

- (void)firstReload:(id)sender
{
    
    [self.tableView reloadData];
    
    if ( _eventShow.description == nil)
    {
        [self performSelector:@selector(firstReload:) withObject:nil afterDelay:0.5];
    }
    else
    {
        if (!_eventShow.cacheCityImage)
        {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.eventShow.image]]];
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [connection start];
        }
        else
        {
            CGFloat headerImageSize;
            CGFloat headerImageWidth;
            
            headerImageWidth = 1024;
            headerImageSize = 300;
            
            _headerImage = [[UIImage imageWithData:_eventShow.cacheCityImage] imageByScalingAndCroppingForSize:CGSizeMake(headerImageWidth, headerImageSize)];
        }
        
        NSString *footerString;
        
        if (self.eventShow.image_author.length == 0)
        {
            footerString = [NSString stringWithFormat:@"%@",self.eventShow.description_author];
        }
        else
        {
            footerString = [NSString stringWithFormat:NSLocalizedString(@"%@<br> Foto por %@", @""),self.eventShow.description_author, self.eventShow.image_author];
        }
        
        htmlStringSimple = [NSString stringWithFormat:HTML_BODY,
                            htmlWidth,
                            self.eventShow.name,
                            self.eventShow.region ?: @"",
                            self.eventShow.description,
                            self.eventShow.description_author ? [NSString stringWithFormat:NSLocalizedString(@"Descripción por %@", @""), footerString] : @""];
        
        [descriptionCell.webView loadHTMLString:htmlStringSimple baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _headerImage = [[UIImage imageWithData:_imageData] imageByScalingAndCroppingForSize:CGSizeMake(1024, 300)];
    
    [self.tableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_imageData)
    {
        _imageData = [[NSMutableData alloc] initWithData:data];
    }
    else
    {
        [_imageData appendData:data];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row)
    {
        case 0: {
            if (self.eventShow.image)
            {
                headerCell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
                
                if (!cell)
                {
                    headerCell = [[TZTripHeaderCell alloc] initWithStyle:0 reuseIdentifier:@"HeaderCell"];
                }
                
                if (!mapIsOn)
                {
                    headerCell.headerImageView.image = _headerImage;
                    headerCell.headerImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                }
                else
                {
                    CGFloat mapSize;
                    
                    mapSize = 500;
                    
                    mapaDetalle = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, mapSize)];
                    mapaDetalle.delegate = self;
                    [headerCell addSubview:mapaDetalle];
                    
                    NSArray *annotationsReady = [[NSArray alloc] init];
                    NSMutableArray *annotationsPrepare = [[NSMutableArray alloc] init];
                    
                    MKCoordinateRegion region;
                    region.center.latitude = _eventShow.lat.floatValue;
                    region.center.longitude = _eventShow.lon.floatValue;
                    
                    for (TZPois *poi in _eventShow.pois)
                    {
                        MKPointAnnotation *annotPoi = [[MKPointAnnotation alloc] init];
                        annotPoi.title = [NSString stringWithFormat:@"%@", poi.name];
                        
                        MKCoordinateRegion regionPoi;
                        regionPoi.center.latitude = poi.lat.floatValue;
                        regionPoi.center.longitude = poi.lon.floatValue;
                        
                        annotPoi.coordinate = regionPoi.center;
                        [annotationsPrepare addObject:annotPoi];
                    }
                    
                    annotationsReady = annotationsPrepare;
                    
                    [mapaDetalle addAnnotations:annotationsReady];
                    
                    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(region.center, 5000, 5000);
                    
                    if ((region.center.latitude >= -90) && (region.center.latitude <= 90) && (region.center.longitude >= -180) && (region.center.longitude <= 180) && (region.center.latitude != -180.00000000) )
                    {
                        @try {
                            [mapaDetalle setRegion:[mapaDetalle regionThatFits:viewRegion] animated:NO];
                        }
                        @catch (NSException *exception) {
                            
                            @try {
                                [mapaDetalle setRegion:[mapaDetalle regionThatFits:viewRegion] animated:NO];
                            }
                            @catch (NSException *exception) {
                                
                            }
                            
                        }
                    }
                }
                
                cell = headerCell;
                
                CGFloat originYToolbar;
                
                if (mapIsOn)
                {
                    originYToolbar = 450;
                }
                else
                {
                    originYToolbar = 250;
                }
                
                UIToolbar *transparentToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, originYToolbar, self.tableView.bounds.size.width, 50)];
                transparentToolbar.alpha = 0.6;
                [cell addSubview:transparentToolbar];
                
                mostrarFicha = [[UIButton alloc] initWithFrame:CGRectMake(0, originYToolbar, allViewSize/5, 50)];
                mostrarFicha.backgroundColor = [UIColor clearColor];
                if (interruptorInfo == 0)
                {
                    [mostrarFicha setImage:[[UIImage imageNamed:@"form"] tintImageWithColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1]] forState:UIControlStateNormal];
                }
                else if (interruptorInfo != 1)
                {
                    [mostrarFicha setImage:[[UIImage imageNamed:@"form"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                }
                
                if (interruptorInfo == 1)
                {
                    [mostrarFicha setImage:[[UIImage imageNamed:@"TrueWhite"] tintImageWithColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1]] forState:UIControlStateNormal];
                }
                
                [mostrarFicha addTarget:self action:@selector(descriptionShow:) forControlEvents:UIControlEventTouchUpInside];
                mostrarFicha.layer.opacity = 0.82;
                [cell addSubview:mostrarFicha];
                
                mostrarBus = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5, originYToolbar, allViewSize/5, 50)];
                mostrarBus.backgroundColor = [UIColor clearColor];
                if (interruptorInfo == 2)
                    [mostrarBus setImage:[[UIImage imageNamed:@"transport"] tintImageWithColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1]] forState:UIControlStateNormal];
                else
                    [mostrarBus setImage:[[UIImage imageNamed:@"transport"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                [mostrarBus addTarget:self action:@selector(busShow:) forControlEvents:UIControlEventTouchUpInside];
                mostrarBus.layer.opacity = 0.82;
                [cell addSubview:mostrarBus];
                
                mostrarRecomend = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5 * 2, originYToolbar, allViewSize/5, 50)];
                mostrarRecomend.backgroundColor = [UIColor clearColor];
                if (interruptorInfo == 3)
                    [mostrarRecomend setImage:[[UIImage imageNamed:@"infoPoint"] tintImageWithColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1]] forState:UIControlStateNormal];
                else
                    [mostrarRecomend setImage:[[UIImage imageNamed:@"infoPoint"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                [mostrarRecomend addTarget:self action:@selector(touristOfficeShow:) forControlEvents:UIControlEventTouchUpInside];
                mostrarRecomend.layer.opacity = 0.82;
                [cell addSubview:mostrarRecomend];
                
                mostrarMapaPois = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5 * 3, originYToolbar, allViewSize/5, 50)];
                mostrarMapaPois.backgroundColor = [UIColor clearColor];
                [mostrarMapaPois setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                mostrarMapaPois.imageView.contentMode = UIViewContentModeScaleAspectFit;
                
                if (!mapIsOn)
                    [mostrarMapaPois setImage:[[UIImage imageNamed:@"Map"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                else
                    [mostrarMapaPois setImage:[[UIImage imageNamed:@"Map"] tintImageWithColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1]] forState:UIControlStateNormal];
                [mostrarMapaPois addTarget:self action:@selector(mapShow:) forControlEvents:UIControlEventTouchUpInside];
                mostrarMapaPois.layer.opacity = 0.82;
                [cell addSubview:mostrarMapaPois];
                
                mostrarCompras = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5 * 4, originYToolbar, allViewSize/5, 50)];
                mostrarCompras.backgroundColor = [UIColor clearColor];
                [mostrarCompras setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                mostrarCompras.imageView.contentMode = UIViewContentModeScaleAspectFit;
                if (interruptorInfo == 4)
                    [mostrarCompras setImage:[[UIImage imageNamed:@"commerce"] tintImageWithColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1]] forState:UIControlStateNormal];
                else
                    [mostrarCompras setImage:[[UIImage imageNamed:@"commerce"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                [mostrarCompras addTarget:self action:@selector(shoppingShow:) forControlEvents:UIControlEventTouchUpInside];
                mostrarCompras.layer.opacity = 0.82;
                [cell addSubview:mostrarCompras];
                
            }
            break;
            
        }
        case 1: {
            switch (interruptorInfo)
            {
                case 0:
                    descriptionCell = [self.tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];
                    
                    if (!descriptionCell)
                    {
                        descriptionCell = [[TZWebDescriptionCell alloc] initWithStyle:0 reuseIdentifier:@"DescriptionCell"];
                        
                        NSString *footerString;
                        
                        if (self.eventShow.image_author.length == 0)
                        {
                            footerString = [NSString stringWithFormat:@"%@",self.eventShow.description_author];
                        }
                        else {
                            footerString = [NSString stringWithFormat:NSLocalizedString(@"%@<br> Foto por %@", @""),self.eventShow.description_author, self.eventShow.image_author];
                        }
                        
                        NSString *htmlString = [NSString stringWithFormat:HTML_BODY,
                                                htmlWidth,
                                                self.eventShow.name,
                                                self.eventShow.region ?: @"",
                                                self.eventShow.description,
                                                self.eventShow.description_author ? [NSString stringWithFormat:NSLocalizedString(@"Descripción por %@", @""), footerString] : @""];
                        
                        descriptionCell.onHeightCallback = ^(CGFloat height) {
                            _descriptionHeight = height;
                            [self.tableView reloadData];
                        };
                        
                        [descriptionCell.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
                    }
                    cell = descriptionCell;
                    break;
                case 1:
                    recomendationCell = [self.tableView dequeueReusableCellWithIdentifier:@"RecomendationCell"];
                    
                    if (!recomendationCell)
                    {
                        recomendationCell = [[TZWebDescriptionCell alloc] initWithStyle:0 reuseIdentifier:@"RecomendationCell"];
                        
                        NSString *htmlString = [NSString stringWithFormat:HTML_BODY,
                                                htmlWidth,
                                                NSLocalizedString(@"Recomendaciones para la ciudad",@""),
                                                self.eventShow.region,
                                                [NSString stringWithFormat:@"<br> %@", self.eventShow.recomendations],
                                                emptyString];
                        
                        recomendationCell.onHeightCallback = ^(CGFloat height) {
                            _recomendationHeight = height;
                            [self.tableView reloadData];
                        };
                        
                        [recomendationCell.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
                    }
                    cell = recomendationCell;
                    break;
                case 2:
                    busCell = [self.tableView dequeueReusableCellWithIdentifier:@"BusCell"];
                    
                    if (!busCell)
                    {
                        busCell = [[TZWebDescriptionCell alloc] initWithStyle:0 reuseIdentifier:@"BusCell"];
                        
                        NSString *htmlString = [NSString stringWithFormat:HTML_BODY,
                                                htmlWidth,
                                                NSLocalizedString(@"Transporte público",@""),
                                                self.eventShow.region,
                                                [NSString stringWithFormat:@"<br> %@", self.eventShow.public_transport],
                                                emptyString];
                        
                        busCell.onHeightCallback = ^(CGFloat height) {
                            _transportHeight = height;
                            [self.tableView reloadData];
                        };
                        
                        [busCell.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
                    }
                    cell = busCell;
                    break;
                case 3:
                    TouristCell = [self.tableView dequeueReusableCellWithIdentifier:@"TouristCell"];
                    
                    if (!TouristCell)
                    {
                        TouristCell = [[TZWebDescriptionCell alloc] initWithStyle:0 reuseIdentifier:@"TouristCell"];
                        
                        NSString *htmlString = [NSString stringWithFormat:HTML_BODY,
                                                htmlWidth,
                                                NSLocalizedString(@"Oficinas de turismo",@""),
                                                self.eventShow.region,
                                                [NSString stringWithFormat:@"<br> %@", self.eventShow.information_offices],
                                                emptyString];
                        
                        TouristCell.onHeightCallback = ^(CGFloat height) {
                            _tourismHeight = height;
                            [self.tableView reloadData];
                        };
                        
                        [TouristCell.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
                    }
                    cell = TouristCell;
                    break;
                case 4:
                    shoppingCell = [self.tableView dequeueReusableCellWithIdentifier:@"ShoppingCell"];
                    
                    if (!shoppingCell)
                    {
                        shoppingCell = [[TZWebDescriptionCell alloc] initWithStyle:0 reuseIdentifier:@"ShoppingCell"];
                        
                        NSString *htmlString = [NSString stringWithFormat:HTML_BODY,
                                                htmlWidth,
                                                NSLocalizedString(@"Horario comercial",@""),
                                                self.eventShow.region,
                                                [NSString stringWithFormat:@"<br> %@", self.eventShow.office_hours],
                                                emptyString];
                        
                        shoppingCell.onHeightCallback = ^(CGFloat height) {
                            _shopHeight = height;
                            [self.tableView reloadData];
                        };
                        
                        [shoppingCell.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
                    }
                    cell = shoppingCell;
                    break;
            }
            
            break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            if (mapIsOn)
            {
                return 500.0f;
            }
            else
            {
                return 300.0f;
            }
        case 1:
            switch (interruptorInfo)
        {
            case 0:
                return _descriptionHeight;
                break;
            case 1:
                return _recomendationHeight;
                break;
            case 2:
                return _transportHeight;
                break;
            case 3:
                return _tourismHeight;
                break;
            case 4:
                return _shopHeight;
                break;
        }
        default:
            return 44.0f;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && !mapIsOn)
    {
        photoController = nil;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        photoController = [storyboard instantiateViewControllerWithIdentifier:@"TriporgImageShow"];
        if (!_eventShow.cacheCityImage)
        {
            photoController.photoData = _imageData;
        }
        else
        {
            photoController.photoData = _eventShow.cacheCityImage;
        }
        
        [self.navigationController pushViewController:photoController animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController])
    {
        interruptorInfo = 0;
        
        mapIsOn = NO;
        
        [mapaDetalle removeFromSuperview];
        mapaDetalle.delegate = nil;
    }
}

- (void)descriptionShow:(id)sender
{
    mapIsOn = NO;
    [mapaDetalle removeFromSuperview];
    [[mapaDetalle subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    mapaDetalle.delegate = nil;
    
    if (RecOrDesc == NO)
    {
        RecOrDesc = YES;
        interruptorInfo = 1;
    }
    else
    {
        RecOrDesc = NO;
        interruptorInfo = 0;
    }
    
    [self.tableView reloadData];
}

- (void)busShow:(id)sender
{
    mapIsOn = NO;
    [mapaDetalle removeFromSuperview];
    [[mapaDetalle subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    mapaDetalle.delegate = nil;
    
    interruptorInfo = 2;
    [self.tableView reloadData];
}

- (void)touristOfficeShow:(id)sender
{
    mapIsOn = NO;
    [mapaDetalle removeFromSuperview];
    [[mapaDetalle subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    mapaDetalle.delegate = nil;
    
    interruptorInfo = 3;
    [self.tableView reloadData];
}

- (void)mapShow:(id)sender
{
    if (!mapIsOn)
    {
        mapIsOn = YES;
        [self.tableView reloadData];
    }
    else
    {
        mapIsOn = NO;
        [mapaDetalle removeFromSuperview];
        [[mapaDetalle subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        mapaDetalle.delegate = nil;
        [self.tableView reloadData];
    }
}

- (void)shoppingShow:(id)sender
{
    mapIsOn = NO;
    [mapaDetalle removeFromSuperview];
    [[mapaDetalle subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    mapaDetalle.delegate = nil;
    
    interruptorInfo = 4;
    [self.tableView reloadData];
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

@end