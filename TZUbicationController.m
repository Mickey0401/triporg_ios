//
//  TZUbicationController.m
//  Triporg
//
//  Created by Koldo Ruiz on 21/10/13.
//
//

#import "TZUbicationController.h"
#import "TZTripEventDetailController.h"
#import "TZCityInfoController.h"
#import "MBProgressHUD.h"
#import "TZTriporgManager.h"
#import "TZLocation.h"
#import "WebImageOperations.h"
#import "UIImage+Additions.h"
#import "FXLabel.h"
#import "TZCityWithDesc.h"

static TZUbicationController *ubicationPush = nil;
static TZTripEventDetailController *eventDetailAnother = nil;
static TZTripEventDetailController *locationDetail = nil;
static TZCityInfoController *cityDetail = nil;

@interface TZUbicationController () {
    UIImage *imageForHeader;
    NSMutableData *_imageData;
    NSString *versioniOS;
}

@end

@implementation TZUbicationController

@synthesize tableView;

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
    
    imageForHeader = [self.imageCity imageByScalingAndCroppingForSize:CGSizeMake(self.view.bounds.size.width, 60)];
    
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.tableView.rowHeight = 60.0f;
    }
    else
    {
        
    }
    
    ubicationsArray = [[NSArray alloc] init];
    
    if (self.isSecond.length == 0)
    {
        self.title = NSLocalizedString(@"Pto. Interés", @"");
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.imageUrl]]];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        [connection start];
        
        ubicationsArray = nil;
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[TZTriporgManager sharedManager] getCityUbications:self.cityId callback:^(id result) {
            
            if ([result isKindOfClass:[NSError class]])
            {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                                message:[((NSError *) result).userInfo objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                ubicationsArray = result;
                
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [self performSelector:@selector(loadUbicationImages:) withObject:nil afterDelay:1];
            }
        }];
    }
    else
    {
        self.title = NSLocalizedString(@"Actividades", @"");
        
        ubicationsArray = nil;
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[TZTriporgManager sharedManager] getEventsOfUbication:self.cityId callback:^(id result) {
            if ([result isKindOfClass:[NSError class]])
            {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                                message:[((NSError *) result).userInfo objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                ubicationsArray = result;
                
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                [self performSelector:@selector(loadUbicationImages:) withObject:nil afterDelay:2];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ubicationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TZLocation *ubication;
    
    ubication = [ubicationsArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *firstDateFormatter = nil;
    if (!firstDateFormatter)
    {
        firstDateFormatter = [[NSDateFormatter alloc] init];
        firstDateFormatter.dateFormat = @"dd-MM HH:mm";
    }
    
    cell.textLabel.text = ubication.nombre;
    cell.detailTextLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (ubication.imageSaved == nil)
    {
        cell.imageView.image = [UIImage imageNamed:@"default-image"];
        
        if (self.tableView.decelerating == NO && !ubication.imageSaved)
        {
            if ([ubication.image rangeOfString:@"default"].location == NSNotFound)
            {
                [WebImageOperations processImageDataWithURLString:[ubication.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"] andBlock:^(NSData *imageData) {
                    
//                    if (cell.imageView.image == [UIImage imageNamed:@"default-image"])
                    {
                        ubication.imageSaved = [UIImage imageWithData:imageData];
                        cell.imageView.image = ubication.imageSaved;
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
        cell.imageView.image = ubication.imageSaved;
    }
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TZLocation *locationGo;
    locationGo = [ubicationsArray objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    
    if (self.isSecond.length == 0)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        
        locationDetail = nil;
        locationDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripEventDetail"];
        
        locationDetail.type = TZTripItemTypeLocation;
        locationDetail.isShowing = @"YES";
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[TZTriporgManager sharedManager] getLocationWithId:locationGo.id callback:^(TZEvent *locationResp) {
            
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
    else
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        [[TZTriporgManager sharedManager] getEventWithId:locationGo.id callback:^(TZEvent *event) {
            
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
                eventDetailAnother.eventShow = nil;
                
                eventDetailAnother = [storyboard instantiateViewControllerWithIdentifier:@"TripEventDetail"];
                eventDetailAnother.eventShow = event;
                [self performSelector:@selector(goToTheEventDetail:) withObject:nil];
            }
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    
    sectionHeaderView.backgroundColor = [UIColor clearColor];
    sectionHeaderView.layer.borderWidth = 0.3f;
    sectionHeaderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    FXLabel *headerLabel = [[FXLabel alloc] initWithFrame:
                            CGRectMake(20, 0, sectionHeaderView.frame.size.width - 60, 60)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeZero;
    headerLabel.shadowBlur = 20.0f;
    
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22]];
    
    headerLabel.textColor = [UIColor whiteColor];
    UIImageView *imageHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderView.frame.size.width, 60)];
    imageHeader.contentMode = UIViewContentModeScaleToFill;
    
    UIButton *buttonDetail = [UIButton buttonWithType:UIButtonTypeInfoLight];
    buttonDetail.frame = CGRectMake(sectionHeaderView.frame.size.width -50, 0, 40, 60);
    [buttonDetail addTarget:self action:@selector(cityPush:) forControlEvents:UIControlEventTouchUpInside];
    buttonDetail.tintColor = [UIColor whiteColor];
    
    UIButton *buttonInvisible = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonInvisible.frame = CGRectMake(0, 0, sectionHeaderView.frame.size.width, 60);
    [buttonInvisible addTarget:self action:@selector(cityPush:) forControlEvents:UIControlEventTouchUpInside];
    buttonInvisible.backgroundColor = [UIColor clearColor];
    
    headerLabel.text = [self.cityName uppercaseString];
    
    imageHeader.image = [imageForHeader tintImageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sectionHeaderView.frame.size.width, 60)];
    
    blackView.backgroundColor = [UIColor clearColor];
    
    [sectionHeaderView addSubview:imageHeader];
    [sectionHeaderView addSubview:blackView];
    [sectionHeaderView addSubview:headerLabel];
    [sectionHeaderView addSubview: buttonDetail];
    [sectionHeaderView addSubview:buttonInvisible];
    
    sectionHeaderView.opaque = YES;
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isSecond.length == 0)
    {
        return 60;
    }
    else
    {
        return 0;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.tableView reloadData];
}

- (void)loadUbicationImages:(id)sender
{
    [self.tableView reloadData];
}

- (void)cityPush:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[TZTriporgManager sharedManager] getCityInfoWithId:self.cityId callback:^(id resp) {
        
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
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
            
            cityDetail = nil;
            cityDetail = [storyboard instantiateViewControllerWithIdentifier:@"cityInfo"];
            
            TZCityWithDesc *event = resp;
            
            cityDetail.eventShow = event;
            
            [self performSelector:@selector(goToTheCityDetail:) withObject:nil];
        }
    }];
}

- (void)goToTheEventDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:eventDetailAnother animated:YES];
}

- (void)goToTheCityDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:cityDetail animated:YES];
}

- (void)goToDetail:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController pushViewController:locationDetail animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    imageForHeader = [[UIImage imageWithData:_imageData] imageByScalingAndCroppingForSize:CGSizeMake(self.view.bounds.size.width, 60)];
    
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


@end
