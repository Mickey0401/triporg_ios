//
//  TZDestinationViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 23/09/13.
//
//

#import "TZDestinationViewController.h"
#import "TZTriporgManager.h"
#import "TZCity.h"
#import "TZMapCity.h"
#import "TZMapCityCoord.h"
#import "NSArray+Additions.h"
#import "TZCreateTripController.h"
#import "MBProgressHUD.h"
#import "UIImage+Additions.h"
#import "WebImageOperations.h"


@interface TZDestinationViewController () {
    NSArray *searchArray;
    NSMutableArray *nameForHeaders;
    NSArray *indexForHeaders;
}

@end

@implementation TZDestinationViewController

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
    
    self.title = NSLocalizedString(@"Destino", @"");
    
    ciudadesArray = [[NSArray alloc] init];
    searchArray = [[NSArray alloc] init];
    
    tableView.sectionIndexColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        tableView.rowHeight = 60.0f;
    }
    
    self.searchMyCity.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    
    // iOS Version
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        self.searchMyCity.searchBarStyle = UISearchBarStyleMinimal;
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancelar", @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelCity:)];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TZTriporgManager sharedManager] refreshAllCities:^(NSArray *cities) {
        
        if ([cities isKindOfClass:[NSError class]])
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                        message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            searchArray = cities;
            
            cities = [cities sortedArrayUsingComparator:^NSComparisonResult(TZCity *c1, TZCity *c2) {
                return [c1.country compare:c2.country];
            }];
            
            // Group cities by country
            NSMutableArray *citiesGrouped = [NSMutableArray array];
            
            NSString *currentCountry;
            NSMutableArray *citiesBlock;
            
            nameForHeaders = [[NSMutableArray alloc] init];
            indexForHeaders = [[NSMutableArray alloc] init];
            
            indexForHeaders = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"Y",@"Z"];
            
            for (TZCity *myCity in cities)
            {
                if ([myCity.country isEqualToString:currentCountry] == NO)
                {
                    currentCountry = myCity.country;
                    citiesBlock = [NSMutableArray array];
                    [citiesGrouped addObject:citiesBlock];
                    [nameForHeaders addObject:currentCountry];
                }
                
                [citiesBlock addObject:myCity];
            }
            ciudadesArray = citiesGrouped;
            
            [self performSelector:@selector(reloadTableView:) withObject:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** Recarga la tabla de destinos */
- (void)reloadTableView:(id)sender
{
    [self.tableView reloadData];
}

/** Cierra la lista de destinos y vuelve al listado de viajes */
- (void)cancelCity:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (_filteredEvents ? 1 : ciudadesArray.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_filteredEvents ? _filteredEvents.count : [[ciudadesArray objectAtIndex:section] count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TZCity *ciudadEvent;
    NSArray *dayItems = [ciudadesArray objectAtIndex:indexPath.section];
    ciudadEvent = _filteredEvents ? [_filteredEvents objectAtIndex:indexPath.row] : [dayItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = ciudadEvent.nombre;
    
    if (ciudadEvent.imageSaved == nil)
    {
        cell.imageView.image = [UIImage imageNamed:@"default-image"];
        
        if (self.tableView.decelerating == NO && !ciudadEvent.imageSaved)
        {
            if ([ciudadEvent.image rangeOfString:@"default"].location == NSNotFound)
            {
                [WebImageOperations processImageDataWithURLString:[ciudadEvent.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"] andBlock:^(NSData *imageData) {
                    
//                    if (cell.imageView.image == [UIImage imageNamed:@"default-image"])
                    {
                        ciudadEvent.imageSaved = [UIImage imageWithData:imageData];
                        cell.imageView.image = ciudadEvent.imageSaved;
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
        cell.imageView.image = ciudadEvent.imageSaved;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, self.tableView.frame.size.width, 25)];
    sectionHeaderView.backgroundColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    sectionHeaderView.alpha = 0.9;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(0, 0, sectionHeaderView.frame.size.width, 25)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:19]];
    headerLabel.textColor = [UIColor whiteColor];
    [sectionHeaderView addSubview:headerLabel];
    
    UIImageView *imageCountry = [[UIImageView alloc] initWithFrame:
                                 CGRectMake(10, 1.5, 22, 22)];
    
    imageCountry.image = [[UIImage imageNamed:@"city"]  tintImageWithColor:[UIColor whiteColor]];
    [sectionHeaderView addSubview:imageCountry];
    
    sectionHeaderView.layer.borderWidth = 0.3f;
    sectionHeaderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    for (NSInteger i = 0; i < nameForHeaders.count; i++)
    {
        if (section == i)
        {
            headerLabel.text = [nameForHeaders objectAtIndex:i];
        }
    }
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!_filteredEvents)
    {
        return 25;
    }
    else
    {
        return 0;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexForHeaders;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    
    TZCity *objetoCiudad;
    
    NSArray *dayItems = [ciudadesArray objectAtIndex:indexPath.section];
    
    objetoCiudad = _filteredEvents ? [_filteredEvents objectAtIndex:indexPath.row] : [dayItems objectAtIndex:indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:objetoCiudad.nombre forKey:@"nombreCiudad"];
    [defaults setObject:objetoCiudad.country forKey:@"nombrePais"];
    [defaults setObject:objetoCiudad.id forKey:@"idCiudad"];
    
    TZMapCity *mapArray;
    NSNumber *sumLat;
    NSNumber *sumLon;
    
    mapArray = [objetoCiudad.map objectAtIndex:0];
    
    for (TZMapCityCoord *coords in mapArray.center)
    {
        sumLat = coords.lat;
        sumLon = coords.lon;
    }
    
    [defaults setObject:sumLat forKey:@"latitudCiudad"];
    [defaults setObject:sumLon forKey:@"longitudCiudad"];
    
    [defaults synchronize];
    
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
        [TZCreateTripController rootElement:^(QRootElement *el) {
            
            UIViewController *createTripController = [[TZCreateTripController alloc] initWithRoot:el];
            
            [self.navigationController pushViewController:createTripController animated:YES];
        }];
    }
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
    
    _filteredEvents = [searchArray collect:^id(TZCity *e)
                       {
                           BOOL match =
                           [e.nombre.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound
                           || [e.country.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound;
                           return match ? e : nil;
                           
                       }];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.tableView reloadData];
}


@end
