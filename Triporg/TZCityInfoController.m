//
//  TZCityInfoController.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZCityInfoController.h"
#import <QuartzCore/QuartzCore.h>
#import "TZTriporgManager.h"
#import "TZCityWithDesc.h"
#import "TZTripHeaderCell.h"
#import "TZWebDescriptionCell.h"
#import "TZTripEventHeader.h"
#import "EPDAlertView.h"
#import "UIImage+Additions.h"
#import "UIColor+String.h"
#import "TZCommentViewController.h"
#import "TZPhotoViewController.h"
#import "TZUbicationController.h"
#import "TZPois.h"
#import "TZContact.h"
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

@interface TZCityInfoController () {
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
    NSInteger actionSheetType;
    NSInteger interruptorInfo;
    CGFloat htmlWidth;
    CGFloat allViewSize;
    BOOL RecOrDesc;
    BOOL mapIsOn;
}

@end

@implementation TZCityInfoController

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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        allViewSize = 1024;
        htmlWidth = 1024 - 20;
    }
    else
    {
        allViewSize = self.view.bounds.size.width;
        htmlWidth = self.view.bounds.size.width - 20;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    UIButton *buttonDetail = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        [buttonDetail setImage:[UIImage imageNamed:@"contact"] forState:UIControlStateNormal];
    }
    else
    {
        [buttonDetail setImage:[[UIImage imageNamed:@"contact"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]] forState:UIControlStateNormal];
    }
    
    buttonDetail.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [buttonDetail addTarget:self action:@selector(generalActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    buttonDetail.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    if (_eventShow.contacts.count == 0 && _eventShow.services.count == 0)
    {
        buttonDetail.hidden = YES;
    }
    
    UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showShareOptions:)];
    
    UIBarButtonItem *contactBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonDetail];
    
    NSArray *buttonsArray = [[NSArray alloc] initWithObjects:shareBarButton, contactBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = buttonsArray;
    
    mapIsOn = NO;
    RecOrDesc = NO;
    emptyString = @"";
    interruptorInfo = 0;
    actionSheetType = 0;
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
            
            if (allViewSize > 320)
            {
                headerImageWidth = 1024;
                headerImageSize = 300;
            }
            else
            {
                headerImageWidth = 320;
                headerImageSize = 200;
            }
            
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
    CGFloat headerImageSize;
    CGFloat headerImageWidth;
    
    if (allViewSize > 320)
    {
        headerImageWidth = 1024;
        headerImageSize = 300;
    }
    else
    {
        headerImageWidth = 320;
        headerImageSize = 200;
    }
    
    _headerImage = [[UIImage imageWithData:_imageData] imageByScalingAndCroppingForSize:CGSizeMake(headerImageWidth, headerImageSize)];
    
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
                    if (allViewSize > 320)
                    {
                        mapSize = 500;
                    }
                    else
                    {
                        mapSize = 300;
                    }
                    
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
                if (mapIsOn) {
                    if (allViewSize > 320)
                    {
                        originYToolbar = 450;
                    }
                    else
                    {
                        originYToolbar = 250;
                    }
                }
                else
                {
                    if (allViewSize > 320)
                    {
                        originYToolbar = 250;
                    }
                    else
                    {
                        originYToolbar = 150;
                    }
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
                        else
                        {
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
                    
                    if (!busCell) {
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
            if (allViewSize > 320)
            {
                if (mapIsOn)
                {
                    return 500.0f;
                }
                else
                {
                    return 300.0f;
                }
            }
            else
            {
                if (mapIsOn)
                {
                    return 300.0f;
                }
                else
                {
                    return 200.0f;
                }
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

- (void)generalActionSheet:(id)sender
{
    actionSheetType = 0;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.delegate = self;
    
    if (_eventShow.contacts.count > 0)
    {
        [sheet addButtonWithTitle:NSLocalizedString(@"Contactos", @"")];
    }
    
    if (_eventShow.services.count > 0)
    {
        [sheet addButtonWithTitle:NSLocalizedString(@"Servicios", @"")];
    }
    
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:NSLocalizedString(@"Cancelar", @"")];
    
    [sheet showInView:self.view];
}

- (void)showContacts:(id)sender
{
    actionSheetType = 1;
    UIActionSheet *actionContact = [[UIActionSheet alloc] init];
    actionContact.delegate = self;
    actionContact.title = NSLocalizedString(@"Contactos", @"");
    
    for (TZContact *contact in _eventShow.contacts)
    {
        [actionContact addButtonWithTitle:contact.method];
    }
    
    actionContact.cancelButtonIndex = [actionContact addButtonWithTitle:NSLocalizedString(@"Cancelar", @"")];
    [actionContact showInView:self.view];
}

- (void)showServices:(id)sender
{
    actionSheetType = 2;
    UIActionSheet *actionService = [[UIActionSheet alloc] init];
    actionService.delegate = self;
    actionService.title = NSLocalizedString(@"Servicios", @"");
    
    for (TZService *service in _eventShow.services)
    {
        [actionService addButtonWithTitle:service.service];
    }
    
    actionService.cancelButtonIndex = [actionService addButtonWithTitle:NSLocalizedString(@"Cancelar", @"")];
    [actionService showInView:self.view];
}

- (void)showShareOptions:(id)sender
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *preferredLang = [languages objectAtIndex:0];
    
    NSString *shareString;
    
    if ([preferredLang isEqual:@"es"])
        shareString = [NSString stringWithFormat:@"Triporg: %@ tu organizador de viajes online.",_eventShow.public_url];
    else
        shareString = [NSString stringWithFormat:@"Triporg: %@ your online trip organizer.",_eventShow.public_url];
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString] applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:shareController];
        self.popover.delegate = self;
        [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:shareController animated:YES completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Cancelar", @"")])
    {
        
    }
    else
    {
        switch (actionSheetType)
        {
            case 0:
                if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Contactos", @"")])
                {
                    [self performSelector:@selector(showContacts:) withObject:nil afterDelay:0.3];
                }
                else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Servicios", @"")])
                {
                    [self performSelector:@selector(showServices:) withObject:nil afterDelay:0.3];
                }
                break;
            case 1:
                if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Cancelar", @"")])
                {
                    TZContact *contact = [_eventShow.contacts objectAtIndex:buttonIndex];
                    if ([contact.abbreviation isEqualToString:@"www"] || [contact.abbreviation isEqualToString:@"g+"] || [contact.abbreviation isEqualToString:@"you"] || [contact.abbreviation isEqualToString:@"w"] || [contact.abbreviation isEqualToString:@"4sq"] || [contact.abbreviation isEqualToString:@"fr"] || [contact.abbreviation isEqualToString:@"fb"] || [contact.abbreviation isEqualToString:@"t"])
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", contact.value]]];
                    }
                    else if ([contact.abbreviation isEqualToString:@"Tel"])
                    {
                        NSString *numberPhone = [contact.value stringByReplacingOccurrencesOfString:@" " withString:@""];
                        numberPhone = [numberPhone stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        numberPhone = [numberPhone stringByReplacingOccurrencesOfString:@")" withString:@""];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", numberPhone]]];
                    }
                    else if ([contact.abbreviation isEqualToString:@"fax"])
                    {
                        NSString *faxNumber = [contact.value stringByReplacingOccurrencesOfString:@" " withString:@""];
                        faxNumber = [faxNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
                        faxNumber = [faxNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
                        [[[EPDAlertView alloc] initWithTitle:@"Fax"
                                                     message:[NSString stringWithFormat:@"%@", faxNumber]
                                                      action:^(NSUInteger index) { }
                                           cancelButtonTitle:NSLocalizedString(@"Ok", @"" )
                                           otherButtonTitles:nil] show];
                    }
                    else if ([contact.abbreviation isEqualToString:@"@"])
                    {
                        if ([MFMailComposeViewController canSendMail])
                        {
                            // Show the mail composer
                            MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
                            emailController.mailComposeDelegate = self;
                            emailController.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
                            NSArray *toRecipents = [NSArray arrayWithObject:contact.value];
                            [emailController setToRecipients:toRecipents];
                            [emailController setSubject:@""];
                            [emailController setMessageBody:@"" isHTML:NO];
                            if (emailController) [self presentViewController:emailController animated:YES completion:nil];
                            
                        }
                        else
                        {
                            // Handle the error
                            
                        }
                    }
                }
                break;
            case 2:
                if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Cancelar", @"")])
                {
                    TZService *service = [_eventShow.services objectAtIndex:buttonIndex];
                    NSString *numberPhone = [service.value stringByReplacingOccurrencesOfString:@" " withString:@""];
                    numberPhone = [numberPhone stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    numberPhone = [numberPhone stringByReplacingOccurrencesOfString:@")" withString:@""];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",numberPhone]]];
                }
                break;
        }
    }
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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
