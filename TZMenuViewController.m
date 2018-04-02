//
//  TZMenuViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 22/08/13.
//
//

#import "TZMenuViewController.h"
#import "TZTriporgManager.h"
#import "MBProgressHUD.h"
#import "TZUserProfileController.h"
#import "UIColor+String.h"
#import "UIImage+Additions.h"
#import "TZUser.h"
#import "TZMenuTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>


@interface TZMenuViewController ()

@end

@implementation TZMenuViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Menú", @"");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Volver", @"")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(exitMenu:)];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    //Initialize the dataArray
    dataArray = [[NSMutableArray alloc] init];
    
    if ([TZTriporgManager sharedManager].currentUser.isAutomatic.integerValue == 1)
    {
        // Zero section data
        NSArray *zeroItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Registrarse", @""), nil];
        NSDictionary *zeroItemsArrayDict = [NSDictionary dictionaryWithObject:zeroItemsArray forKey:@"data"];
        [dataArray addObject:zeroItemsArrayDict];
    }
    
    // First section data
    NSArray *firstItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Perfil", @""), NSLocalizedString(@"Intereses", @""), nil];
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
    [dataArray addObject:firstItemsArrayDict];
    
    // Second section data
    NSArray *secondItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Ver Ciudades",@""), NSLocalizedString(@"Cerca de mí", @""), NSLocalizedString(@"Reservas", @""), nil];
    NSDictionary *secondItemsArrayDict = [NSDictionary dictionaryWithObject:secondItemsArray forKey:@"data"];
    [dataArray addObject:secondItemsArrayDict];
    
    // Third section data
    NSArray *thirdItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Ayuda", @""), NSLocalizedString(@"Sugerencias", @""), NSLocalizedString(@"Acerca de", @""), nil];
    NSDictionary *thirdItemsArrayDict = [NSDictionary dictionaryWithObject:thirdItemsArray forKey:@"data"];
    [dataArray addObject:thirdItemsArrayDict];
    
    // Four section data
    NSArray *fourItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Desconectar", @""), nil];
    NSDictionary *fourItemsArrayDict = [NSDictionary dictionaryWithObject:fourItemsArray forKey:@"data"];
    [dataArray addObject:fourItemsArrayDict];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.rowHeight = 60.0f;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exitMenu:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)goToTheUserPanel:(id)sender
{
    [[TZUserProfileController alloc] initWithCallback:^(TZUserProfileController *userProfile) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [self.navigationController pushViewController:userProfile animated:YES];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of rows it should expect should be based on the section
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TZMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[TZMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    NSString *cellValue = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    
    if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Perfil", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"Profile"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Intereses", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"interestsG"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Ver Ciudades", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"city"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Cerca de mí", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"signal"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Reservas", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"booking"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Ayuda", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"help"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Sugerencias", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"idea"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Acerca de", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"TriporgWhite"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Desconectar", @"")])
    {
        cell.imageView.image = [UIImage imageNamed:@"logout"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"Registrarse", @"")])
    {
        cell.imageView.image = [[UIImage imageNamed:@"email"] tintImageWithColor:[UIColor whiteColor]];
        cell.backgroundColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:0.9];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mostrarPerfil = nil;
    
    NSString *selectedCell = nil;
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    selectedCell = [array objectAtIndex:indexPath.row];
    
    if ([selectedCell isEqualToString:NSLocalizedString(@"Perfil", @"")])
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
            mostrarPerfil = @"perfil";
            [defaults setObject:mostrarPerfil forKey:@"codigoperfil"];
            [defaults synchronize];
            
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            [self performSelector:@selector(goToTheUserPanel:) withObject:nil];
        }
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Intereses", @"")])
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
            mostrarPerfil = @"generales";
            [defaults setObject:mostrarPerfil forKey:@"codigoperfil"];
            [defaults synchronize];
            
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            [self performSelector:@selector(goToTheUserPanel:) withObject:nil];
        }
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Ver Ciudades", @"")])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *collectionCityController = [storyboard instantiateViewControllerWithIdentifier:@"collectCitiesFix"];
        
        [self.navigationController pushViewController:collectionCityController animated:YES];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Cerca de mí", @"")])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *nearPlacesController = [storyboard instantiateViewControllerWithIdentifier:@"nearPlaces"];
        
        [self.navigationController pushViewController:nearPlacesController animated:YES];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Reservas", @"")])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *collectionCityController = [storyboard instantiateViewControllerWithIdentifier:@"reservasGo"];
        
        [self.navigationController pushViewController:collectionCityController animated:YES];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Ayuda", @"")])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *helpController = [storyboard instantiateViewControllerWithIdentifier:@"Helping"];
        
        [self.navigationController pushViewController:helpController animated:YES];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Sugerencias", @"")])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *suggestionController = [storyboard instantiateViewControllerWithIdentifier:@"Suggestion"];
        
        [self.navigationController pushViewController:suggestionController animated:YES];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Acerca de", @"")])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        UIViewController *aboutController = [storyboard instantiateViewControllerWithIdentifier:@"aboutTriporg"];
        
        [self.navigationController pushViewController:aboutController animated:YES];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Desconectar", @"")])
    {
        if (FBSession.activeSession.isOpen)
        {
            [FBSession.activeSession closeAndClearTokenInformation];
        }
        
        [self dismissViewControllerAnimated:NO completion:^{
            [[TZTriporgManager sharedManager] logout];
        }];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Registrarse", @"")])
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
            [self callTheRegisterWindow:nil];
        }
    }
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
    
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
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
                                
                                dataArray = [[NSMutableArray alloc] init];
                                
                                // First section data
                                NSArray *firstItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Perfil", @""), NSLocalizedString(@"Intereses", @""), nil];
                                NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
                                [dataArray addObject:firstItemsArrayDict];
                                
                                // Second section data
                                NSArray *secondItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Ver Ciudades",@""), NSLocalizedString(@"Cerca de mí", @""), NSLocalizedString(@"Reservas", @""), nil];
                                NSDictionary *secondItemsArrayDict = [NSDictionary dictionaryWithObject:secondItemsArray forKey:@"data"];
                                [dataArray addObject:secondItemsArrayDict];
                                
                                // Third section data
                                NSArray *thirdItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Ayuda", @""), NSLocalizedString(@"Sugerencias", @""), NSLocalizedString(@"Acerca de", @""), nil];
                                NSDictionary *thirdItemsArrayDict = [NSDictionary dictionaryWithObject:thirdItemsArray forKey:@"data"];
                                [dataArray addObject:thirdItemsArrayDict];
                                
                                // Four section data
                                NSArray *fourItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Desconectar", @""), nil];
                                NSDictionary *fourItemsArrayDict = [NSDictionary dictionaryWithObject:fourItemsArray forKey:@"data"];
                                [dataArray addObject:fourItemsArrayDict];

                                [self.tableView reloadData];
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
            
        }
    }
    else if (alertView.tag == 7)
    {
        [self callTheRegisterWindow:nil];
    }
    else if (alertView.tag == 22)
    {
        [self dismissViewControllerAnimated:NO completion:^{
            [[TZTriporgManager sharedManager] logout];
        }];
    }
}

@end

