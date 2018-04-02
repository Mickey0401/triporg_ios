//
//  TZRestrictionListViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 06/09/13.
//
//

#import "TZRestrictionListController.h"
#import "TZTriporgManager.h"
#import "TZTripEvent.h"
#import "TZTrip.h"
#import "TZCreateTripController.h"
#import "TZTripsTableController.h"
#import "MBProgressHUD.h"
#import "UIImage+Additions.h"
#import "TZRestrictionAddController.h"

static TZRestrictionAddController *addRestrictionView = nil;


@interface TZRestrictionListController () {
    NSNumber *tripId;
    NSUserDefaults *defaults;
    NSString *headerString;
    NSString *subHeaderString;
    NSString *middleString;
    BOOL pushBlock;
}

@end

@implementation TZRestrictionListController

@synthesize hotelActive;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Listado Citas", @"");
    
    pushBlock = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.createTripButton.title = NSLocalizedString(@"Continuar", @"");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(keepAdding:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancelar", @"") style:UIBarButtonItemStylePlain target:self action:@selector(goToDestination:)];
    
    citasArray = [[NSArray alloc] init];
    
    defaults = [NSUserDefaults standardUserDefaults];
    tripId = [defaults objectForKey:@"idViajeFinal"];
    
    NSDateFormatter *firstDateFormatter = nil;
    if (!firstDateFormatter)
    {
        firstDateFormatter = [[NSDateFormatter alloc] init];
        firstDateFormatter.dateFormat = @"dd-MM-yyyy HH:mm";
    }
    
    NSString *fechaInicio = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:[defaults objectForKey:@"fechaInicioViaje"]]];
    NSString *fechaFinal = [NSString stringWithFormat:@"%@",[firstDateFormatter stringFromDate:[defaults objectForKey:@"fechaFinalViaje"]]];
    
    headerString = [NSString stringWithFormat:NSLocalizedString(@"Viaje a %@", @""), [defaults objectForKey:@"nombreCiudad"]];
    subHeaderString = [NSString stringWithFormat:@"%@ / %@",fechaInicio, fechaFinal];
    middleString = [defaults objectForKey:@"nombreCiudad"];
    
    citasArray = nil;
    
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self performSelector:@selector(firstAdding:) withObject:nil afterDelay:1.2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [self performSelector:@selector(reloadCitas:) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)firstAdding:(id)sender
{
    pushBlock = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    addRestrictionView = nil;
    addRestrictionView = [storyboard instantiateViewControllerWithIdentifier:@"Citas"];
    addRestrictionView.restrictionNumber = [NSNumber numberWithInteger:citasArray.count + 1];
    
    [self.navigationController pushViewController:addRestrictionView animated:YES];
}

- (void)keepAdding:(id)sender
{
    if (pushBlock != NO)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        addRestrictionView = nil;
        addRestrictionView = [storyboard instantiateViewControllerWithIdentifier:@"Citas"];
        addRestrictionView.restrictionNumber = [NSNumber numberWithInteger:citasArray.count + 1];
        
        [self.navigationController pushViewController:addRestrictionView animated:YES];
    }
}

- (void)reloadCitas:(id)sender
{
    citasArray = nil;
    [[TZTriporgManager sharedManager] showRestrictionListWithId:tripId callback:^(id result)
     {
         if ([result isKindOfClass:[NSError class]])
         {
             [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                             message:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                   otherButtonTitles:nil];
             [alert show];
         }
         else
         {
             citasArray = result;
             
             [self.tableView reloadData];
             [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
         }
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return citasArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TZTripEvent *citasEvent;
    
    citasEvent = [citasArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *firstDateFormatter = nil;
    if (!firstDateFormatter)
    {
        firstDateFormatter = [[NSDateFormatter alloc] init];
        firstDateFormatter.dateFormat = @"dd-MM HH:mm";
    }
    NSString *fechaCitasInicio = [NSString stringWithFormat:@"%@", [firstDateFormatter stringFromDate:citasEvent.start]];
    NSString *fechaCitasFin = [NSString stringWithFormat:@"%@", [firstDateFormatter stringFromDate:citasEvent.end]];
    
    cell.textLabel.text = citasEvent.name;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ / %@", fechaCitasInicio, fechaCitasFin];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    cell.imageView.image = [UIImage imageNamed:@"appointment-image"];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
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
            TZTripEvent *citasDelete;
            citasDelete = [citasArray objectAtIndex:indexPath.row];
            
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [[TZTriporgManager sharedManager] deleteRestrictionListWithId:citasDelete.id callback:^(id result) {
                [self performSelector:@selector(reloadCitas:) withObject:nil];
                
            }];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)index
{
    UIView *toolbarHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    toolbarHeader.backgroundColor = [UIColor whiteColor];
    UILabel *titleTrip = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, self.view.bounds.size.width - 10, 20)];
    titleTrip.textAlignment = NSTextAlignmentCenter;
    titleTrip.textColor = [UIColor darkGrayColor];
    titleTrip.text = headerString;
    [toolbarHeader addSubview:titleTrip];
    
    UILabel *cityTrip = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.view.bounds.size.width - 10, 20)];
    cityTrip.textAlignment = NSTextAlignmentCenter;
    cityTrip.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    cityTrip.textColor = [UIColor grayColor];
    cityTrip.text = middleString;
    [toolbarHeader addSubview:cityTrip];
    
    UILabel *subtitleTrip = [[UILabel alloc] initWithFrame:CGRectMake(10, 53, self.view.bounds.size.width - 10, 20)];
    subtitleTrip.textAlignment = NSTextAlignmentCenter;
    subtitleTrip.textColor = [UIColor grayColor];
    subtitleTrip.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    subtitleTrip.text = subHeaderString;
    [toolbarHeader addSubview:subtitleTrip];
    
    UIImageView *believeView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 79, self.tableView.bounds.size.width - 15, 0.5)];
    believeView.layer.opacity = 1;
    believeView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"CellHeaderBackground"] tintImageWithColor:[UIColor lightGrayColor]]];
    [toolbarHeader addSubview:believeView];
    
    return toolbarHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)index
{
    return 80;
}

- (IBAction)finalShowdown:(id)sender
{
    [defaults removeObjectForKey:@"readyForResctriction"];
    [defaults synchronize];
    
    if (hotelActive.length == 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
        hud.detailsLabelText = NSLocalizedString(@"Calculando el mejor itinerario", @"");
        
        [[TZTriporgManager sharedManager] generateFinalTrip:tripId callback:^(id result) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kTZTripCreated object:nil];
            }];
        }];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *hotelView = [storyboard instantiateViewControllerWithIdentifier:@"hotel"];
        
        [self.navigationController pushViewController:hotelView animated:YES];
    }
}

- (void)goToDestination:(id)sender
{
    [defaults removeObjectForKey:@"readyForResctriction"];
    [defaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
