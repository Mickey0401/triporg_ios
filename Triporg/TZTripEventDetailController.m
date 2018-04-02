//
//  TZTripEventDetailController.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTripEventDetailController.h"
#import <QuartzCore/QuartzCore.h>
#import "TZTriporgManager.h"
#import "TZTripEvent.h"
#import "TZTripHeaderCell.h"
#import "TZWebDescriptionCell.h"
#import "TZTripEventHeader.h"
#import "MBProgressHUD.h"
#import "EPDAlertView.h"
#import "UIImage+Additions.h"
#import "UIColor+String.h"
#import "TZCalendar.h"
#import "TZCommentViewController.h"
#import "TZPhotoViewController.h"
#import "TZUbicationController.h"
#import "TZContact.h"

#define HTML_BODY   \
@"<!DOCTYPE html>\
<html>\
<head>\
<style>body { font-family: HelveticaNeue; width: %fpx; margin: 0; padding: 5px 10px; text-align: left; } footer {font-family: HelveticaNeue-UltraLight; display: block; color: gray; font-style: italic; font-size: 10px; text-align: right } .tipoActividad { font-family: HelveticaNeue-Light; font-style: italic; color: %@; font-size: 14px; margin-bottom: 3px; } h3 { font-family: HelveticaNeue-Bold;  margin-bottom: 0; padding-bottom: 0; } </style>\
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

static TZTripEventDetailController *locationDetail;
static TZCommentViewController *commentController;
static TZPhotoViewController *photoController;
static TZUbicationController *ubicationPush = nil;

@interface TZTripEventDetailController () {
    UIButton *mostrarEstrellas;
    UIButton *mostrarUbicacion;
    UIButton *mostrarHorario;
    UIButton *mostrarCompras;
    UIButton *mostrarMapaEvento;
    UIImage *estrellaFinal;
    DLStarRatingControl *ratingControl;
    TZWebDescriptionCell *descriptionCell;
    TZWebDescriptionCell *timeTableCell;
    TZTripHeaderCell *headerCell;
    MKMapView *mapaDetalle;
    NSString *repeat;
    NSString *days;
    NSString *schedule;
    NSString *price;
    NSString *exact;
    NSString *emptyString;
    NSString *versioniOS;
    NSInteger puntuacionEstrellas;
    CGFloat htmlWidth;
    CGFloat allViewSize;
    BOOL timeTable;
    BOOL mapIsOn;
}

@end

@implementation TZTripEventDetailController

@synthesize type = _type;
@synthesize eventShow = _eventShow;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch (_type)
    {
        case TZTripItemTypeEvent:
            self.title = NSLocalizedString(@"Evento", @"");
            break;
            
        default:
            self.title = NSLocalizedString(@"Ubicación", @"");
            break;
    }
    
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
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
        self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    buttonDetail.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [buttonDetail addTarget:self action:@selector(showContacts:) forControlEvents:UIControlEventTouchUpInside];
    buttonDetail.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    if (_eventShow.contacts.count == 0)
    {
        buttonDetail.hidden = YES;
    }
    
    UIBarButtonItem *shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareInformation:)];
    
    UIBarButtonItem *contactBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonDetail];
    
    NSArray *buttonsArray = [[NSArray alloc] initWithObjects:shareBarButton, contactBarButton, nil];
    
    self.navigationItem.rightBarButtonItems = buttonsArray;
    
    timeTable = NO;
    mapIsOn = NO;
    emptyString = @"";
    puntuacionEstrellas = _eventShow.rate.integerValue;
    
    if (!puntuacionEstrellas)
    {
        puntuacionEstrellas = 0;
    }
    
    switch (puntuacionEstrellas)
    {
        case 0:
            estrellaFinal = [[UIImage imageNamed:@"star1"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 1:
            estrellaFinal = [[UIImage imageNamed:@"star1"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 2:
            estrellaFinal = [[UIImage imageNamed:@"star2"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 3:
            estrellaFinal = [[UIImage imageNamed:@"star3"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 4:
            estrellaFinal = [[UIImage imageNamed:@"star4"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 5:
            estrellaFinal = [[UIImage imageNamed:@"star5"] tintImageWithColor:[UIColor blackColor]];
            break;
    }
    
    _descriptionHeight = 200;
    _timeTableHeight = 120;
    
    // Colocar un footer de tamaño 0 impide que se dibujen separator lines en las celdas vacias en iOS 7
    UIView *footer =
    [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    [self performSelector:@selector(firstReload:) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
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
        NSString *footerString;
        
        if (self.eventShow.image_author.length == 0)
        {
            footerString = [NSString stringWithFormat:@"%@",self.eventShow.description_author];
        }
        else
        {
            footerString = [NSString stringWithFormat:NSLocalizedString(@"%@<br> Foto por %@", @""),self.eventShow.description_author, self.eventShow.image_author];
        }
        
        NSString *htmlStringSimple = [NSString stringWithFormat:HTML_BODY,
                                      htmlWidth,
                                      self.eventShow.color,
                                      self.eventShow.name,
                                      self.eventShow.type_location ?: @"",
                                      self.eventShow.description,
                                      self.eventShow.description_author ? [NSString stringWithFormat:NSLocalizedString(@"Descripción por %@", @""), footerString] : @""];
        
        [descriptionCell.webView loadHTMLString:htmlStringSimple baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
    }
}

- (void)shareInformation:(id)sender
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
    if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Cancelar", @"")])
    {
        TZContact *contact = [_eventShow.contacts objectAtIndex:buttonIndex];
        
        if ([contact.abbreviation isEqualToString:@"www"] || [contact.abbreviation isEqualToString:@"g+"] || [contact.abbreviation isEqualToString:@"you"] || [contact.abbreviation isEqualToString:@"w"] || [contact.abbreviation isEqualToString:@"4sq"] || [contact.abbreviation isEqualToString:@"fr"] || [contact.abbreviation isEqualToString:@"fb"] || [contact.abbreviation isEqualToString:@"t"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",contact.value]]];
        }
        else if ([contact.abbreviation isEqualToString:@"Tel"])
        {
            NSString *numberPhone = [contact.value stringByReplacingOccurrencesOfString:@" " withString:@""];
            numberPhone = [numberPhone stringByReplacingOccurrencesOfString:@"(" withString:@""];
            numberPhone = [numberPhone stringByReplacingOccurrencesOfString:@")" withString:@""];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",numberPhone]]];
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
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                        message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
        }
        else
        {
            NSString *inputText = [[alertView textFieldAtIndex:0] text];
            if (inputText.length == 0)
            {
                inputText = [NSString stringWithFormat:@"Un usuario ha reportado contenido en %@",_eventShow.name];
            }
            
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = NSLocalizedString(@"Hecho", @"");
            
            [HUD show:NO];
            [HUD hide:YES afterDelay:1.5];
            
            if (_type == TZTripItemTypeEvent)
            {
                [[TZTriporgManager sharedManager] SendReportMessage:_eventShow.id text:inputText type:@"e" callback:^(id result) {
                }];
            }
            else
            {
                [[TZTriporgManager sharedManager] SendReportMessage:_eventShow.id text:inputText type:@"u" callback:^(id result) {
                }];
            }
        }
    }
}

- (void)newRating:(DLStarRatingControl *)control :(CGFloat)rating
{
    puntuacionEstrellas = lroundf(rating);
    
    [[TZTriporgManager sharedManager] rateEventWithEvent:_eventShow rate:[NSNumber numberWithInteger:puntuacionEstrellas] callback:^(id result) {
        
    }];
    
    [self performSelector:@selector(StarHide:) withObject:nil afterDelay:0.5];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //  return _type == TZTripItemTypeLocation ? 5 : 4;
    
    if ( _type == TZTripItemTypeLocation &&  self.isShowing.length > 0)
    {
        return 5;
    }
    else
    {
        return 4;
    }
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
                    CGFloat headerImageSize;
                    if (allViewSize > 320) {
                        headerImageSize = 300;
                    }
                    else
                    {
                        headerImageSize = 200;
                    }
                    
                    headerCell.headerImageView.image = [[UIImage imageWithData:_eventShow.cacheEventImage] imageByScalingAndCroppingForSize:CGSizeMake(self.tableView.bounds.size.width, headerImageSize)];
                    
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
                    
                    MKCoordinateRegion region;
                    region.center.latitude = _eventShow.lat.floatValue;
                    region.center.longitude = _eventShow.lon.floatValue;
                    
                    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
                    annot.title = [NSString stringWithFormat:@"%@", _eventShow.name];
                    annot.coordinate = region.center;
                    
                    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(region.center, 500, 500);
                    
                    [mapaDetalle addAnnotation:annot];
                    
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
                
                switch (_type)
                {
                    case TZTripItemTypeEvent:{
                        
                        CGFloat originYToolbar;
                        if (mapIsOn)
                        {
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
                        
                        ratingControl = [[DLStarRatingControl alloc] initWithFrame:CGRectMake(0, originYToolbar, self.tableView.bounds.size.width, 70)];
                        ratingControl.backgroundColor = [UIColor clearColor];
                        ratingControl.delegate = self;
                        [cell addSubview:ratingControl];
                        ratingControl.hidden = YES;
                        
                        mostrarHorario = [[UIButton alloc] initWithFrame:CGRectMake(0, originYToolbar, allViewSize/5, 50)];
                        mostrarHorario.backgroundColor = [UIColor clearColor];
                        
                        if (timeTable == NO)
                        {
                            [mostrarHorario setImage:[[UIImage imageNamed:@"timePrice"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                        }
                        else
                        {
                            [mostrarHorario setImage:[[UIImage imageNamed:@"form.png"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                        }
                        
                        [mostrarHorario addTarget:self action:@selector(horarioShow:) forControlEvents:UIControlEventTouchUpInside];
                        mostrarHorario.layer.opacity = 0.82;
                        
                        [cell addSubview:mostrarHorario];
                        
                        mostrarEstrellas = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5, originYToolbar, allViewSize/5, 50)];
                        mostrarEstrellas.backgroundColor = [UIColor clearColor];
                        [mostrarEstrellas setImage:estrellaFinal forState:UIControlStateNormal];
                        [mostrarEstrellas addTarget:self action:@selector(StarShow:) forControlEvents:UIControlEventTouchUpInside];
                        mostrarEstrellas.layer.opacity = 0.82;
                        
                        [cell addSubview:mostrarEstrellas];
                        
                        mostrarUbicacion = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5 * 2, originYToolbar, allViewSize/5, 50)];
                        mostrarUbicacion.backgroundColor = [UIColor clearColor];
                        [mostrarUbicacion setImage:[[UIImage imageNamed:@"poi"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                        [mostrarUbicacion addTarget:self action:@selector(UbicationShow:) forControlEvents:UIControlEventTouchUpInside];
                        mostrarUbicacion.layer.opacity = 0.82;
                        [mostrarUbicacion setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                        mostrarUbicacion.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                        [cell addSubview:mostrarUbicacion];
                        
                        mostrarMapaEvento = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5 * 3, originYToolbar, allViewSize/5, 50)];
                        mostrarMapaEvento.backgroundColor = [UIColor clearColor];
                        [mostrarMapaEvento setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                        mostrarMapaEvento.imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
                        if (!mapIsOn)
                        {
                            [mostrarMapaEvento setImage:[[UIImage imageNamed:@"Map"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                        }
                        else
                        {
                            [mostrarMapaEvento setImage:[[UIImage imageNamed:@"Map"] tintImageWithColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1]] forState:UIControlStateNormal];
                        }
                        
                        [mostrarMapaEvento addTarget:self action:@selector(mapShow:) forControlEvents:UIControlEventTouchUpInside];
                        mostrarMapaEvento.layer.opacity = 0.82;
                        
                        [cell addSubview:mostrarMapaEvento];
                        
                        mostrarCompras = [[UIButton alloc] initWithFrame:CGRectMake(allViewSize/5 * 4 , originYToolbar, allViewSize/5, 50)];
                        mostrarCompras.backgroundColor = [UIColor clearColor];
                        
                        if (_eventShow.purchase_link.length == 0)
                        {
                            [mostrarCompras setImage:[[UIImage imageNamed:@"tickets"] tintImageWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
                        }
                        else
                        {
                            [mostrarCompras setImage:[[UIImage imageNamed:@"tickets"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                        }
                        
                        [mostrarCompras addTarget:self action:@selector(ComprasShow:) forControlEvents:UIControlEventTouchUpInside];
                        mostrarCompras.layer.opacity = 0.82;
                        
                        [cell addSubview:mostrarCompras];
                        
                    }
                        break;
                        
                    default:{
                        
                    }
                        
                        break;
                }
                
            }
            else
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Blank"];
            }
            break;
        }
        case 1: {
            
            if (timeTable == NO)
            {
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
                                            self.eventShow.color,
                                            self.eventShow.name,
                                            self.eventShow.type_location ?: @"",
                                            self.eventShow.description,
                                            self.eventShow.description_author ? [NSString stringWithFormat:NSLocalizedString(@"Descripción por %@", @""), footerString] : @""];
                    
                    descriptionCell.onHeightCallback = ^(CGFloat height) {
                        _descriptionHeight = height;
                        [self.tableView reloadData];
                    };
                    
                    [descriptionCell.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
                }
                cell = descriptionCell;
            }
            else
            {
                timeTableCell = [self.tableView dequeueReusableCellWithIdentifier:@"TimeTableCell"];
                
                if (!timeTableCell)
                {
                    timeTableCell = [[TZWebDescriptionCell alloc] initWithStyle:0 reuseIdentifier:@"TimeTableCell"];
                    
                    NSString *infoHorario;
                    
                    for (TZCalendar *calendario in _eventShow.calendar)
                    {
                        repeat = calendario.months;
                        days = calendario.days;
                        schedule = calendario.schedule;
                        price = calendario.price;
                        exact = calendario.exact;
                        NSString *sumadorHorario = [NSString stringWithFormat:@"%@, %@ %@ * %@",repeat ,days ,schedule ,price];
                        if (sumadorHorario.length != 0)
                        {
                            infoHorario = [NSString stringWithFormat:@"%@ <br> <br> %@",sumadorHorario, infoHorario];
                        }
                        
                        infoHorario = [infoHorario stringByReplacingOccurrencesOfString:@"(null)" withString:@" "];
                    }
                    
                    NSString *htmlStringU = [NSString stringWithFormat:HTML_BODY,
                                             htmlWidth,
                                             @"#93D31B",
                                             NSLocalizedString(@"Horario", @""),
                                             self.eventShow.location ?: @"",
                                             [NSString stringWithFormat:@"<br> %@", infoHorario],
                                             emptyString];
                    
                    timeTableCell.onHeightCallback = ^(CGFloat height) {
                        _timeTableHeight = height;
                        [self.tableView reloadData];
                    };
                    
                    [timeTableCell.webView loadHTMLString:htmlStringU baseURL:[NSURL URLWithString:@"https://www.triporg.org"]];
                    
                }
                cell = timeTableCell;
                
            }
            break;
        }
            
        case 2: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
            
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReportCell"];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor grayColor];
                cell.imageView.image = [[UIImage imageNamed:@"circle"] tintImageWithColor:[UIColor grayColor]];
                cell.textLabel.text = NSLocalizedString(@"Reportar Contenido", @"");
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
            
        case 3: {
            
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShowCommentCell"];
            
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ShowCommentCell"];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor colorWithString:@"#93D31B"];
                cell.imageView.image = [[UIImage imageNamed:@"edit"] tintImageWithColor:[UIColor colorWithString:@"#93D31B"]];
                cell.textLabel.text = NSLocalizedString(@"Ver Comentarios", @"");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            break;
        }
            
        case 4: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShowActivitiesCell"];
            
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ShowActivitiesCell"];
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor colorWithString:@"#93D31B"];
                cell.imageView.image = [[UIImage imageNamed:@"see"] tintImageWithColor:[UIColor colorWithString:@"#93D31B"]];
                cell.textLabel.text = NSLocalizedString(@"Ver Actividades", @"");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
            if (!timeTable)
            {
                return _descriptionHeight;
            }
            else
            {
                return _timeTableHeight;
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
        photoController.photoData = _eventShow.cacheEventImage;
        
        [self.navigationController pushViewController:photoController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Reportar Contenido", @"")
                              message:nil
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Cancelar", @"")
                              otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *answerField = [alert textFieldAtIndex:0];
        
        if ([versioniOS hasPrefix:@"6."])
        {
            
        }
        else
        {
            answerField.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
        }
        
        answerField.placeholder = NSLocalizedString(@"(Opcional) Sugiere un cambio.", @"");
        [alert show];
    }
    else if (indexPath.row == 3)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        
        commentController = nil;
        commentController = [storyboard instantiateViewControllerWithIdentifier:@"commentShow"];
        commentController.eventId = _eventShow.id;
        commentController.eventName = _eventShow.name;
        commentController.type = _type;
        
        if (_type == TZTripItemTypeEvent)
        {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [[TZTriporgManager sharedManager] getEventCommentList:_eventShow.id callback:^(id result) {
                
                if ([result isKindOfClass:[NSArray class]])
                {
                    commentController.commentsArray = result;
                    [self performSelector:@selector(goToTheComments:) withObject:nil];
                }
                else
                {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                }
            }];
        }
        else
        {
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [[TZTriporgManager sharedManager] getLocationCommentList:_eventShow.id callback:^(id result) {
                
                if ([result isKindOfClass:[NSArray class]])
                {
                    commentController.commentsArray = result;
                    [self performSelector:@selector(goToTheComments:) withObject:nil];
                }
                else
                {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                }
            }];
        }
    }
    else if (indexPath.row == 4)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        ubicationPush = nil;
        ubicationPush = [storyboard instantiateViewControllerWithIdentifier:@"InvestigateList"];
        ubicationPush.cityId = _eventShow.id;
        ubicationPush.cityName = _eventShow.name;
        ubicationPush.isSecond = @"YES";
        
        [self.navigationController pushViewController:ubicationPush animated:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController])
    {
        puntuacionEstrellas = 0;
        
        timeTable = NO;
        mapIsOn = NO;
        
        [mapaDetalle removeFromSuperview];
        mapaDetalle.delegate = nil;
    }
}

- (void)goToTheComments:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:commentController animated:YES];
}

- (void)UbicationShow:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    
    locationDetail = nil;
    locationDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripEventDetail"];
    locationDetail.type = TZTripItemTypeLocation;
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[TZTriporgManager sharedManager] getLocationWithId:_eventShow.location_id callback:^(TZEvent *locationResp) {
        
        if ([locationResp isKindOfClass:[NSError class]])
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
            locationDetail.eventShow = locationResp;
            [self performSelector:@selector(goToDetail:) withObject:nil];
        }
    }];
}

- (void)goToDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:locationDetail animated:YES];
}

- (void)ComprasShow:(id)sender
{
    NSString *URLBuy = _eventShow.purchase_link;
    
    if (URLBuy.length == 0)
    {
        
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",URLBuy]]];
    }
}

- (void)horarioShow:(id)sender
{
    if (timeTable == NO)
    {
        [UIView transitionWithView:mostrarHorario duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                               [mostrarHorario setImage:[[UIImage imageNamed:@"form.png"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                           } completion:nil];
        timeTable = YES;
        
        UIView *footer =
        [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footer;
        
        [self.tableView reloadData];
    }
    else
    {
        [UIView transitionWithView:mostrarHorario duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                               [mostrarHorario setImage:[[UIImage imageNamed:@"timePrice"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
                           } completion:nil];
        timeTable = NO;
        
        UIView *footer =
        [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footer;
        
        [self.tableView reloadData];
    }
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

- (void)StarShow:(id)sender
{
    [UIView transitionWithView:ratingControl duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                           mostrarEstrellas.hidden = YES;
                           mostrarHorario.hidden = YES;
                           mostrarUbicacion.hidden = YES;
                           mostrarCompras.hidden = YES;
                           mostrarMapaEvento.hidden = YES;
                           ratingControl.hidden = NO;
                       } completion:nil];
}

- (void)StarHide:(id)sender
{
    [UIView transitionWithView:ratingControl duration:0.2
                       options:UIViewAnimationOptionCurveEaseIn animations:^{
                           [mostrarEstrellas setImage:estrellaFinal forState:UIControlStateNormal];
                           mostrarEstrellas.hidden = NO;
                           mostrarHorario.hidden = NO;
                           mostrarUbicacion.hidden = NO;
                           mostrarCompras.hidden = NO;
                           mostrarMapaEvento.hidden = NO;
                           ratingControl.hidden = YES;
                       } completion:nil];
    
    [self performSelector:@selector(RellenarOne:) withObject:nil afterDelay:0.3];
}

- (void)RellenarOne:(id)sender
{
    switch (puntuacionEstrellas)
    {
        case 0:
            estrellaFinal = [[UIImage imageNamed:@"star1"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 1:
            estrellaFinal = [[UIImage imageNamed:@"star1"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 2:
            estrellaFinal = [[UIImage imageNamed:@"star2"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 3:
            estrellaFinal = [[UIImage imageNamed:@"star3"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 4:
            estrellaFinal = [[UIImage imageNamed:@"star4"] tintImageWithColor:[UIColor blackColor]];
            break;
        case 5:
            estrellaFinal = [[UIImage imageNamed:@"star5"] tintImageWithColor:[UIColor blackColor]];
            break;
    }
    
    [UIView transitionWithView:mostrarEstrellas duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           [mostrarEstrellas setImage:estrellaFinal forState:UIControlStateNormal];
                       } completion:nil];
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

- (void)showContacts:(id)sender
{
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


@end
