//
//  TZTripsTableController.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTripsTableController.h"
#import "TZUserProfileController.h"
#import "TZTripCell.h"
#import "TZTrip.h"
#import "TZTriporgManager.h"
#import "TZLoginViewController.h"
#import "TZTripEventsTableController.h"
#import "TZiPadListViewController.h"
#import "MBProgressHUD.h"
#import "TZCreateTripController.h"
#import "EPDAlertView.h"
#import "UIImage+Additions.h"
#import "TZCityWithDesc.h"
#import <QuartzCore/QuartzCore.h>

static TZTripEventsTableController *tripDetail;
static TZiPadListViewController *tripDetailiPad;

@interface TZTripsTableController () {
    NSUserDefaults *defaults;
    UIRefreshControl *refreshControl;
    NSString *versioniOS;
    BOOL Loading;
}

- (void)loadTrips;

@end

@implementation TZTripsTableController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Mis viajes", @"");
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Menú", @"") style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTrip:)];
    
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.tableView.rowHeight = 80.0f;
    }
    else
    {
        self.tableView.rowHeight = 60.0f;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshTrips:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.tableView.alwaysBounceVertical = YES;
    
    [self performSelector:@selector(checkUpdate:) withObject:nil afterDelay:4];
    
    // El usuario acaba de iniciar la sesion
    [[NSNotificationCenter defaultCenter] addObserverForName:kTZUserLoggedIn object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         _trips = nil;
         
         [[TZTriporgManager sharedManager] getNewUk:^(id callback) {
             
             [self loadTrips];
             
             [[TZTriporgManager sharedManager] expulseAutomaticUsers];
             
             [self performSelector:@selector(checkMessages:) withObject:nil afterDelay:2];
         }];
     }];
    
    // El usuario acaba de crear un viaje
    [[NSNotificationCenter defaultCenter] addObserverForName:kTZTripCreated object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         [self tripCreated];
     }];
    
    // El usuario se acaba de desconectar
    [[NSNotificationCenter defaultCenter] addObserverForName:kTZUserLogout object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         _trips = nil;
         [self.tableView reloadData];
         
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
         TZLoginViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
         [self.navigationController presentViewController:loginController animated:NO completion:nil];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![TZTriporgManager sharedManager].userLoggedIn)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        TZLoginViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"Login"];
        
        [self presentViewController:loginController animated:NO completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/** Cuando creas un viaje se llama a esta funcion que limpia el cache y te introduce automaticamente en el visor del itinerario */
- (void)tripCreated
{
    defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *transicional = [defaults objectForKey:@"idViajeFinal"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
        tripDetailiPad = nil;
        tripDetailiPad = [storyboard instantiateViewControllerWithIdentifier:@"iPadBegins"];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        tripDetail = nil;
        tripDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripDetail"];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TZTriporgManager sharedManager] getTripWithId:transicional callback:^(TZTrip *trip) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // Limpiar cache del proceso de crear viaje.
        defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults removeObjectForKey:@"nombrePais"];
        [defaults removeObjectForKey:@"nombreCiudad"];
        [defaults removeObjectForKey:@"idCiudad"];
        [defaults removeObjectForKey:@"latitudCiudad"];
        [defaults removeObjectForKey:@"longitudCiudad"];
        [defaults removeObjectForKey:@"idViajeFinal"];
        [defaults removeObjectForKey:@"fechaInicioViaje"];
        [defaults removeObjectForKey:@"fechaFinalViaje"];
        
        // Refrescar el listado de viajes.
        [self refreshTrips:nil];
        
        if ([trip isKindOfClass:[NSError class]])
        {
            [[[EPDAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"" )
                                         message:NSLocalizedString(@"El viaje no se ha podido cargar. Conéctate a Internet y vuelve a intentarlo", @"" )
                                          action:^(NSUInteger index) { }
                               cancelButtonTitle:NSLocalizedString(@"Ok", @"" )
                               otherButtonTitles:nil] show];
            return;
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                tripDetailiPad.editing = NO;
                tripDetailiPad.trip = trip;
                [self performSelector:@selector(goToTheTrip:) withObject:nil];
            }
            else
            {
                tripDetail.editing = NO;
                tripDetail.trip = trip;
                [self performSelector:@selector(goToTheTrip:) withObject:nil];
            }
        }
    }];
}

/** Comprueba que estemos usando la versión mas actualizada de Triporg */
- (void)checkUpdate:(id)sender
{
    if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable)
    {
        
    }
    else
    {
        NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        [[TZTriporgManager sharedManager] checkUpdatesOnAppStoreWithVersion:currentVersion];
    }
}

/** Comprueba si tenemos mensajes nuevos de Triporg */
- (void)checkMessages:(id)sender
{
    if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable)
    {
        
    }
    else
    {
        [[TZTriporgManager sharedManager] sendMessageToTheUser];
    }
}

/** Abre el panel del menu */
- (void)showMenu:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    UIViewController *menuController = [storyboard instantiateViewControllerWithIdentifier:@"MenuShow"];
    UINavigationController *menuNavController = [[UINavigationController alloc] initWithRootViewController:menuController];
    
    [self presentViewController:menuNavController animated:YES completion:nil];
}

/** Abre el panel de nuevo viaje */
- (void)addTrip:(id)sender
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
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *cityController = [storyboard instantiateViewControllerWithIdentifier:@"citySelector"];
        UINavigationController *cityFinal = [[UINavigationController alloc] initWithRootViewController:cityController];
        [self presentViewController:cityFinal animated:YES completion:nil];
    }
}

/** Funcion que carga los viajes del usuarios y te lleva a crear uno nuevo si tienes 0 viajes */
- (void)loadTrips
{
    Loading = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TZTriporgManager sharedManager] getAllTripsCallback:^(id trips) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([trips isKindOfClass:[NSArray class]])
        {
            _trips = trips;
            
            /*static BOOL shouldShowNewTrip = YES;
            
            if (((NSArray *)trips).count == 0 && shouldShowNewTrip && [TZTriporgManager sharedManager].reachability.currentReachabilityStatus
                != NotReachable)
            {
                [self performSelector:@selector(addTrip:) withObject:nil afterDelay:1];
                
                shouldShowNewTrip = NO;
            } */
            
            [self.tableView reloadData];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                            message:NSLocalizedString(@"No se ha podido obtener el listado de viajes. Conéctate a Internet y vuelve a intentarlo.", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        Loading = NO;
    }];
}

/** Recarga los viajes del usuario  */
- (void)refreshTrips:(id)sender
{
    if (Loading == NO)
    {
        Loading = YES;
        [[TZTriporgManager sharedManager] refreshAllTripsCallback:^(id trips) {
            
            if ([trips isKindOfClass:[NSArray class]])
            {
                _trips = trips;
                
                [self.tableView reloadData];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                message:NSLocalizedString(@"No se ha podido obtener el listado de viajes. Conéctate a Internet y vuelve a intentarlo.", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
            if ([refreshControl isRefreshing])
            {
                [refreshControl endRefreshing];
            }
            
            Loading = NO;
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_trips.count != 0)
    {
        return 0;
    }
    else
    {
        return self.tableView.bounds.size.height;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_trips.count == 0)
    {
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        viewHeader.backgroundColor = [UIColor whiteColor];
        
        UILabel *noCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.tableView.bounds.size.width - 30, 250)];
        noCommentLabel.text = NSLocalizedString(@"Crea tu primer viaje.\n¡Anímate y comienza una nueva aventura!", @"");
        noCommentLabel.numberOfLines = 0;
        noCommentLabel.textColor = [UIColor lightGrayColor];
        noCommentLabel.textAlignment = NSTextAlignmentCenter;
        noCommentLabel.backgroundColor = [UIColor clearColor];
        
        [viewHeader addSubview:noCommentLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 170, self.tableView.bounds.size.width, 38)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [[UIImage imageNamed:@"TriporgWhite"] tintImageWithColor:[UIColor lightGrayColor]];
        
        [viewHeader addSubview:imageView];
        
        return viewHeader;
    }
    else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const TripCellIdentifier = @"TripCell";
    
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/YY";
    }
    
    TZTripCell *cell = [tableView dequeueReusableCellWithIdentifier:TripCellIdentifier];
    
    if (!cell)
    {
        cell = [[TZTripCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TripCellIdentifier];
    }
    
    TZTrip *trip = [_trips objectAtIndex:indexPath.row];
    cell.textLabel.text = trip.trip_name;
    
    NSString *downloadKey = [NSString stringWithFormat:@"download$%@", trip.id];
    NSString *testKey = [defaults objectForKey:downloadKey];
    NSString *synchroKey = [NSString stringWithFormat:@"synchro$%@", trip.id];
    NSString *dateSynchro = [defaults objectForKey:synchroKey];
    
    if ([downloadKey isEqualToString:testKey])
    {
        [cell.downloadButton setHidden:YES];
        [cell.cacheCleanerButton setHidden:NO];
        cell.photoDownload.image = [[UIImage imageNamed:@"download-ok"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]];
        [cell.fechaSincro setHidden:NO];
        [cell.fechaSincro setText:dateSynchro];
    }
    else
    {
        [cell.downloadButton setHidden:NO];
        [cell.cacheCleanerButton setHidden:YES];
        [cell.fechaSincro setHidden:YES];
        cell.photoDownload.image = [[UIImage imageNamed:@"download"] tintImageWithColor:[UIColor lightGrayColor]];
    }
    
    cell.onDownloadCallback = ^(id cell)
    {
        const id onDownload = ^(NSUInteger index) {
            if (index != 1)
                return;
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            
            HUD.labelText = NSLocalizedString(@"Descargando Datos",@"");
            HUD.detailsLabelText = NSLocalizedString(@"Mostrará el viaje aun sin conexión",@"");
            
            [HUD show:YES];
            
            [[TZTriporgManager sharedManager] downloadAllTheTrip:trip.id callback:^(TZTrip *tripX)
             {
                 if ([tripX isKindOfClass:[NSError class]] || [tripX.events count] == 0)
                 {
                     [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                                     message:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                                    delegate:nil
                                                           cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                           otherButtonTitles:nil];
                     [alert show];
                     
                 }
                 else
                 {
                     HUD.detailsLabelText = [NSString stringWithFormat:@"0 %%"];
                     
                     NSInteger arrayPosition = 0;
                     __block NSInteger activitiesCount = 0;
                     __block NSInteger hotelOrRestrictionCount = 0;
                     NSInteger tripEventsCount = tripX.events.count;
                     
                     [[TZTriporgManager sharedManager] downloadCityInfoWithId:tripX.city_id callback:^(TZCityWithDesc *city)
                      {
                          
                      }];
                     
                     for (__strong TZEvent *eventosCompletos in tripX.events)
                     {
                         eventosCompletos = [tripX.events objectAtIndex:arrayPosition];
                         if ([eventosCompletos.id isEqualToNumber:[NSNumber numberWithInteger:0]] ||  [eventosCompletos.id_location isEqualToNumber:[NSNumber numberWithInteger:0]])
                         {
                             hotelOrRestrictionCount ++;
                             NSInteger downloadedAct = ((hotelOrRestrictionCount + activitiesCount) * 100) / tripEventsCount;
                             HUD.detailsLabelText = [NSString stringWithFormat:@"%d %%",downloadedAct];
                             //NSLog(@"ACTIVIY: %d HOTEL: %d TOTAL: %d", activitiesCount ,hotelOrRestrictionCount , tripEventsCount);
                             
                             if (activitiesCount + hotelOrRestrictionCount >= tripEventsCount - 1)
                             {
                                 [self performSelector:@selector(downloadFinished:) withObject:nil afterDelay:0.1];
                             }
                         }
                         else
                         {
                             [[TZTriporgManager sharedManager] getEventWithId:eventosCompletos.id callback:^(TZEvent *event)
                              {
                                  
                              }];
                             
                             [[TZTriporgManager sharedManager] getLocationWithId:eventosCompletos.id_location callback:^(TZEvent *location)
                              {
                                  if ([location isKindOfClass:[NSError class]])
                                  {
                                      [self performSelector:@selector(downloadError:) withObject:nil afterDelay:0.1];
                                  }
                                  else
                                  {
                                      activitiesCount ++;
                                      
                                      NSInteger downloadedAct = ((hotelOrRestrictionCount + activitiesCount) * 100) / tripEventsCount;
                                      HUD.detailsLabelText = [NSString stringWithFormat:@"%d %%",downloadedAct];
                                      //NSLog(@"ACTIVIY: %d HOTEL: %d TOTAL: %d", activitiesCount ,hotelOrRestrictionCount , tripEventsCount);
                                      
                                      if (activitiesCount + hotelOrRestrictionCount >= tripEventsCount - 1)
                                      {
                                          [self performSelector:@selector(downloadFinished:) withObject:nil afterDelay:0.1];
                                      }
                                  }
                              }];
                         }
                         arrayPosition++;
                     }
                 }
             }];
            
        };
        
        EPDAlertView *confirmAlert = [[EPDAlertView alloc] initWithTitle:NSLocalizedString(@"¿Descargar los datos del viaje?", @"" )
                                                                 message:NSLocalizedString(@"Así podrás ver tu viaje sin conexión." , @"" )
                                                                  action:onDownload
                                                       cancelButtonTitle:NSLocalizedString(@"Cancelar" , @"" )
                                                       otherButtonTitles:NSLocalizedString(@"Ok", @"" ), nil];
        [confirmAlert show];
    };
    
    cell.onCacheCallback = ^(id cell)
    {
        const id onCache = ^(NSUInteger index) {
            if (index != 1)
                return;
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            
            HUD.labelText = NSLocalizedString(@"Borrando Datos",@"");
            HUD.detailsLabelText = NSLocalizedString(@"El viaje requerirá conexión",@"");
            
            [HUD show:YES];
            
            [[TZTriporgManager sharedManager] removeCacheOfTrip:trip.id callback:^(TZTrip *tripY)
             {
                 [self performSelector:@selector(deleteCacheFinished:) withObject:nil afterDelay:0.1];
                 NSString *downloadKey = [NSString stringWithFormat:@"download$%@", trip.id];
                 [defaults removeObjectForKey:downloadKey];
                 [defaults synchronize];
             }];
        };
        EPDAlertView *confirmAlert = [[EPDAlertView alloc] initWithTitle:NSLocalizedString(@"¿Borrar los datos del viaje?", @"" )
                                                                 message:NSLocalizedString(@"Necesitarás conexión para ver el viaje." , @"" )
                                                                  action:onCache
                                                       cancelButtonTitle:NSLocalizedString(@"Cancelar" , @"" )
                                                       otherButtonTitles:NSLocalizedString(@"Ok", @"" ), nil];
        [confirmAlert show];
        
    };
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", trip.country, [dateFormatter stringFromDate:trip.start], [dateFormatter stringFromDate:trip.end]];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    TZTrip *trip = [_trips objectAtIndex:indexPath.row];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPadStoryboard" bundle:nil];
        tripDetailiPad = nil;
        tripDetailiPad = [storyboard instantiateViewControllerWithIdentifier:@"iPadBegins"];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        tripDetail = nil;
        tripDetail = [storyboard instantiateViewControllerWithIdentifier:@"TripDetail"];
    }
    
    [[TZTriporgManager sharedManager] getTripWithId:trip.id callback:^(TZTrip *trip) {
        
        if ([trip isKindOfClass:[NSError class]])
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"")
                                                              message:NSLocalizedString(@"El viaje no se ha podido cargar. Conéctate a Internet y vuelve a intentarlo", @"" )
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                                    otherButtonTitles:nil];
            [message show];
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                tripDetailiPad.editing = NO;
                tripDetailiPad.trip = trip;
                [self performSelector:@selector(goToTheTrip:) withObject:nil];
            }
            else
            {
                tripDetail.editing = NO;
                tripDetail.trip = trip;
                [self performSelector:@selector(goToTheTrip:) withObject:nil];
            }
        }
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TZTrip *trip = [_trips objectAtIndex:indexPath.row];
    
    if (Loading == NO)
    {
        Loading = YES;
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[TZTriporgManager sharedManager] removeTripWithId:trip.id callback:^(id result) {
            
            if ([result isKindOfClass:[NSError class]])
            {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                            message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                  otherButtonTitles:nil] show];
                Loading = NO;
            }
            else
            {
                [[TZTriporgManager sharedManager] refreshAllTripsCallback:^(id trips) {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
                    Loading = NO;
                    
                    if ([trips isKindOfClass:[NSArray class]])
                    {
                        _trips = trips;
                        
                        [self.tableView reloadData];
                        
                        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                        [self.navigationController.view addSubview:HUD];
                        
                        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
                        
                        // Set custom view mode
                        HUD.mode = MBProgressHUDModeCustomView;
                        
                        //HUD.delegate = self
                        HUD.labelText = NSLocalizedString(@"Eliminado", @"");
                        
                        [HUD show:NO];
                        [HUD hide:YES afterDelay:1.0];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                                        message:NSLocalizedString(@"No se ha podido obtener el listado de viajes. Conéctate a Internet y vuelve a intentarlo.", @"")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }];
            }
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _trips.count;
}

/** Te lleva al visor del itinerario */
- (void)goToTheTrip:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
        [self.navigationController pushViewController:tripDetailiPad animated:YES];
    }
    else
    {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
        [self.navigationController pushViewController:tripDetail animated:YES];
    }
}

/** Funcion que se ejecuta cuando se finaliza la descarga */
- (void)downloadFinished:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"Descarga Completa", @"");
    
    [HUD show:NO];
    [HUD hide:YES afterDelay:1.5];
    
    [self.tableView reloadData];
}

/** Funcion que se ejecuta cuando la descarga falla */
- (void)downloadError:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"Descarga Completa", @"");
    
    [HUD show:NO];
    [HUD hide:YES afterDelay:1.5];
    
    [self.tableView reloadData];
}

/** Funcion que se ejecuta cuando se termina de borrar el cache de un viaje descargado */
- (void)deleteCacheFinished:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"Datos Eliminados", @"");
    
    [HUD show:NO];
    [HUD hide:YES afterDelay:1.5];
    
    [self.tableView reloadData];
}

@end
