//
//  TZUserProfileController.m
//  Triporg
//
//  Created by Endika Salas on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZUserProfileController.h"
#import "TZTriporgManager.h"
#import "TZUser.h"
#import "NSArray+Additions.h"
#import "TZKeyValue.h"
#import "TZInterest.h"
#import "TZTreeFloatEntry.h"
#import "UIColor+String.h"
#import "UIImage+Additions.h"
#import "MBProgressHUD.h"
#import "TZPhotoViewController.h"
#import <QuartzCore/QuartzCore.h>


static TZPhotoViewController *photoController;

NSString *const kTZUserLogout = @"kTZUserLogout";

void setInterestsToSection(NSArray *interests, QSection *section, void(^onChange)(TZTreeFloatEntry *)) {
    
    for (TZInterest *interest in interests)
    {
        TZTreeFloatEntry *treeFloat = [[TZTreeFloatEntry alloc] init];
        treeFloat.onChange = onChange;
        treeFloat.userInfo = interest;
        treeFloat.title = interest.name;
        treeFloat.floatValue = (interest.value.floatValue - 1) / 4;
        
        [section addElement:treeFloat];
        
        if (interest.children && interest.children.count)
        {
            QSection *childSection = [[QSection alloc] initWithTitle:interest.name];
            treeFloat.sections = [NSMutableArray arrayWithObject:childSection];
            
            setInterestsToSection(interest.children, childSection, onChange);
        }
    }
}

@interface TZUserProfileController () {
    UIImage *profileImage;
    NSString *versioniOS;
    BOOL profileImageOn;
    BOOL imageDeleted;
}

@end

@implementation TZUserProfileController


+ (void)rootElement:(TZUserProfileController *)delegate callback:(void(^)(QRootElement *))callback
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mostrarCampos = [defaults objectForKey:@"codigoperfil"];
    
    if ([mostrarCampos isEqualToString:@"perfil"])
    {
        [TZTriporgManager.sharedManager showProfile:^(TZUser *user) {
            
            QRootElement *root = [[QRootElement alloc] init];
            root.title = NSLocalizedString(@"Perfil", @"");
            
            root.grouped = YES;
            QSection *section = [[QSection alloc] init];

            
            QEntryElement *nameElement = [[QEntryElement alloc] initWithKey:@"name"];
            nameElement.delegate = delegate;
            nameElement.title = NSLocalizedString(@"Nombre", @"");
            nameElement.placeholder = NSLocalizedString(@"Tú nombre", @"");
            nameElement.textValue = @"";//user.name;
            [section addElement:nameElement];
            
            QEntryElement *surnameElement = [[QEntryElement alloc] initWithKey:@"surname"];
            surnameElement.delegate = delegate;
            surnameElement.title = NSLocalizedString(@"Apellidos", @"");
            surnameElement.placeholder = NSLocalizedString(@"Tus apellidos", @"");
            surnameElement.textValue = user.surname;
            [section addElement:surnameElement];
            
                        QEntryElement *nicknameElement = [[QEntryElement alloc] initWithKey:@"nickname"];
                        nicknameElement.delegate = delegate;
                        nicknameElement.title = NSLocalizedString(@"Usuario", @"");
                        nicknameElement.placeholder = NSLocalizedString(@"Usuario", @"");
                        nicknameElement.textValue = user.nickname;
                        [section addElement:nicknameElement];
            
            
            QRadioElement *sex = [[QRadioElement alloc] initWithKey:@"gender"];
            sex.title = NSLocalizedString(@"Sexo", @"");

            NSArray *genderItems = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Masculino", @""), NSLocalizedString(@"Femenino", @""), nil];
            NSArray *genderValues = [[NSArray alloc] initWithObjects:@"M", @"F", nil];

            sex.items = genderItems;
            sex.values = genderValues;
            sex.selected = [sex.values indexOfObject:user.gender];
            sex.delegate = delegate;
            sex.onSelected = ^{
                [delegate QEntryDidEndEditingElement:sex andCell:nil];
            };
            [section addElement:sex];

            QDateTimeInlineElement *date = [[QDateTimeInlineElement alloc] initWithKey:@"birthdate"];
            date.title = NSLocalizedString(@"Fecha Nacimiento", @"");
            date.delegate = delegate;
            date.mode = UIDatePickerModeDate;
            if (user.birthdate)
            {
                NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
                dateFromatter.dateFormat = @"yyyy-MM-dd";
                date.dateValue = [dateFromatter dateFromString:user.birthdate];
            }
            [section addElement:date];


            
            [root addSection:section];
            
            section = [[QSection alloc] init];

            {
                QRadioElement *radioElem = [[QRadioElement alloc] initWithKey:@"country"];
                radioElem.title = NSLocalizedString(@"País", @"");
                [[TZTriporgManager sharedManager] getCountries:^(NSArray *paises) {
                    @try {
                        radioElem.items = [paises collect:^id(TZKeyValue *k) { return k.name; }];
                        radioElem.values = [paises collect:^id(TZKeyValue *k) { return k.id; }];
                        radioElem.selected = [radioElem.values indexOfObject:user.country];
                        [delegate.quickDialogTableView reloadCellForElements:radioElem, nil];
                    }
                    @catch (NSException *exception) {
                        // NSLog(@"%@", exception);
                    }
                    
                }];
                radioElem.delegate = delegate;
                radioElem.onSelected = ^{
                    [delegate QEntryDidEndEditingElement:radioElem andCell:nil];
                    
                    [[TZTriporgManager sharedManager] getRegionsForCountryId:radioElem.selectedValue callback:^(NSArray *regiones) {
                        @try {
                            QRadioElement *el = (QRadioElement *) [root elementWithKey:@"region"];
                            [el updateItems:[regiones collect:^id(TZKeyValue *k) { return k.name; }]
                                  forValues:[regiones collect:^id(TZKeyValue *k) { return k.id; }]];
                            el.selectedValue = nil;
                            [delegate.quickDialogTableView reloadCellForElements:el, nil];
                            
                            el = (QRadioElement *) [root elementWithKey:@"city"];
                            [el updateItems:@[]
                                  forValues:@[]];
                            el.selectedValue = nil;
                            [delegate.quickDialogTableView reloadCellForElements:el, nil];
                            
                            [delegate.quickDialogTableView reloadData];
                        }
                        @catch (NSException *exception) {
                            //NSLog(@"%@", exception);
                        }
                        
                    }];
                };
                [section addElement:radioElem];
            }
            
            {
                QRadioElement *radioElem = [[QRadioElement alloc] initWithKey:@"region"];
                radioElem.title = NSLocalizedString(@"Región", @"");
                [radioElem updateItems:@[] forValues:@[]];
                if (user.country)
                {
                    [[TZTriporgManager sharedManager] getRegionsForCountryId:user.country callback:^(NSArray *regiones) {
                        @try {
                            radioElem.items = [regiones collect:^id(TZKeyValue *k) { return k.name; }];
                            radioElem.values = [regiones collect:^id(TZKeyValue *k) { return k.id; }];
                            radioElem.selected = [radioElem.values indexOfObject:user.region];
                            [delegate.quickDialogTableView reloadCellForElements:radioElem, nil];
                        }
                        @catch (NSException *exception) {
                            //  NSLog(@"%@", exception);
                        }
                        
                    }];
                }
                radioElem.delegate = delegate;
                radioElem.onSelected = ^{
                    [delegate QEntryDidEndEditingElement:radioElem andCell:nil];
                    
                    [[TZTriporgManager sharedManager] getCitiesForCountryId:user.country regionId:radioElem.selectedValue callback:^(NSArray *ciudades) {
                        @try {
                            QRadioElement *el = (QRadioElement *) [root elementWithKey:@"city"];
                            [el updateItems:[ciudades collect:^id(TZKeyValue *k) { return k.name; }]
                                  forValues:[ciudades collect:^id(TZKeyValue *k) { return k.id; }]];          //guru
                            //                            [el updateCell:[ciudades collect:^id(TZKeyValue *k) { return k.name; }] selectedValue:[ciudades collect:^id(TZKeyValue *k) { return k.id; }]];
                            el.selected = 0;
                            [delegate.quickDialogTableView reloadCellForElements:el, nil];
                            [delegate.quickDialogTableView reloadData];
                        }
                        @catch (NSException *exception) {
                            // NSLog(@"%@", exception);
                        }
                        
                    }];
                };
                [section addElement:radioElem];
            }
            
            {
                QRadioElement *radioElem = [[QRadioElement alloc] initWithKey:@"city"];
                radioElem.title = NSLocalizedString(@"Ciudad", @"");
                [radioElem updateItems:@[] forValues:@[]];    //guru
                //[radioElem updateCell:@[] selectedValue:@[]];
                if (user.country && user.region)
                {
                    [[TZTriporgManager sharedManager] getCitiesForCountryId:user.country regionId:user.region callback:^(NSArray *ciudades) {
                        @try {
                            radioElem.items = [ciudades collect:^id(TZKeyValue *k) { return k.name; }];
                            radioElem.values = [ciudades collect:^id(TZKeyValue *k) { return k.id; }];
                            radioElem.selected = [radioElem.values indexOfObject:user.city];
                            [delegate.quickDialogTableView reloadCellForElements:radioElem, nil];
                        }
                        @catch (NSException *exception) {
                            // NSLog(@"%@", exception);
                        }
                        
                    }];
                }
                radioElem.delegate = delegate;
                radioElem.onSelected = ^{ [delegate QEntryDidEndEditingElement:radioElem andCell:nil]; };
                [section addElement:radioElem];
            }
            

            [root addSection:section];
            
            section = [[QSection alloc] init];
            
            QButtonElement *lenguage = [[QButtonElement alloc] init];
            lenguage.title = NSLocalizedString(@"Cambiar Idioma", @"");
            lenguage.controllerAction = @"lenguageChange:";
//            lenguage.color = [UIColor darkTextColor];             //guru
            
            [section addElement:lenguage];
            
            QButtonElement *changePassword = [[QButtonElement alloc] init];
            changePassword.title = NSLocalizedString(@"Cambiar Contraseña", @"");
            changePassword.controllerAction = @"passwordChange:";
//            changePassword.color = [UIColor darkTextColor];          //guru
            [section addElement:changePassword];
            
            [root addSection:section];
            
            callback(root);
            
        }];
    }
    else if ([mostrarCampos isEqualToString:@"generales"])
    {
        [[TZTriporgManager sharedManager] showInterest:^(id resp)
         {
             QRootElement *root = [[QRootElement alloc] init];
             
             root.grouped = YES;
             root.title = NSLocalizedString(@"Intereses Generales", @"");
             
             QSection *section = [[QSection alloc] init];
             
             NSMutableArray *interestArray = [[NSMutableArray alloc] init];
             
             for (TZUser *userInterest in resp)
             {
                 NSNumber *interestValue = userInterest.value;
                 interestValue = [NSNumber numberWithFloat:(interestValue.floatValue - 1) / 4.0f];
                 [interestArray addObject:interestValue];
             }
             
             NSNumber *entertainment = [interestArray objectAtIndex:0];
             NSNumber *gastronomy = [interestArray objectAtIndex:1];
             NSNumber *conferences = [interestArray objectAtIndex:2];
             NSNumber *sports = [interestArray objectAtIndex:3];
             NSNumber *celebrations = [interestArray objectAtIndex:4];
             NSNumber *nature = [interestArray objectAtIndex:5];
             NSNumber *culture = [interestArray objectAtIndex:6];
             NSNumber *others = [interestArray objectAtIndex:7];
             NSNumber *monuments = [interestArray objectAtIndex:8];
             
             CGFloat rowHeight;
             
             if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
             {
                 rowHeight = 60;
             }
             else
             {
                 rowHeight = 44;
             }
             
             QFloatElement *el;
             
             el = [[QFloatElement alloc] initWithKey:@"entretenimiento_y_ocio"];
             el.title = NSLocalizedString(@"Entret. y ocio", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(1);
             el.floatValue = entertainment.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){
                 [delegate QEntryDidEndEditingElement:elem andCell:nil];
             };
             //el.onSelected = {}
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"gastronomia"];
             el.title = NSLocalizedString(@"Gastronomía", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(2);
             el.floatValue = gastronomy.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"ferias_y_conferencias"];
             el.title = NSLocalizedString(@"Conferencias", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(3);
             el.floatValue = conferences.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"deporte"];
             el.title = NSLocalizedString(@"Deporte", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(4);
             el.floatValue = sports.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"fiestas_populares_y_festivales"];
             el.title = NSLocalizedString(@"Fiestas Populares", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(5);
             el.floatValue = celebrations.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"naturaleza_y_paisajes"];
             el.title = NSLocalizedString(@"Naturaleza", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(6);
             el.floatValue = nature.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"cultura_y_actividades_educativas"];
             el.title = NSLocalizedString(@"Cultura", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(7);
             el.floatValue = culture.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"otros"];
             el.title = NSLocalizedString(@"Otros", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(8);
             el.floatValue = others.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             el = [[QFloatElement alloc] initWithKey:@"edificios_y_monumentos"];
             el.title = NSLocalizedString(@"Monumentos", @"");
             el.tag = -2;
             el.height = rowHeight;
             el.userInfo = @(9);
             el.floatValue = monuments.floatValue;
             el.maximumValue = 5;
             el.onChange = ^(QFloatElement *elem){[delegate QEntryDidEndEditingElement:elem andCell:nil];};
             
             [section addElement:el];
             
             [root addSection:section];
             
             section = [[QSection alloc] init];
             
             QButtonElement *generalInterestButton = [[QButtonElement alloc] init];
             generalInterestButton.title = NSLocalizedString(@"Intereses de Actividades", @"");
             generalInterestButton.enabled = YES;
             generalInterestButton.color = [UIColor blackColor];
             generalInterestButton.controllerAction = @"activityInt:";
             [section addElement:generalInterestButton];
             
             QButtonElement *locationInterestButton = [[QButtonElement alloc] init];
             locationInterestButton.title = NSLocalizedString(@"Intereses de Ubicaciones", @"");
             locationInterestButton.enabled = YES;
             locationInterestButton.color = [UIColor blackColor];
             locationInterestButton.controllerAction = @"locationInt:";
             [section addElement:locationInterestButton];
             
             [root addSection:section];
             
             callback(root);
         }];
    }
    else if ([mostrarCampos isEqualToString:@"actividades"])
    {
        QRootElement *root = [[QRootElement alloc] init];
        root.grouped = YES;
        
        [[TZTriporgManager sharedManager] getActivitySpecificInterests:^(NSArray *lists) {
            
            if ([lists isKindOfClass:NSArray.class])
            {
                void(^onChangeActivity)(TZTreeFloatEntry *) = ^(TZTreeFloatEntry *entry) {
                    TZInterest *interest = entry.userInfo;
                    interest.value = @(entry.floatValue*4+1);
                    [[TZTriporgManager sharedManager] editActivitiesSpecificInterestsWithId:interest.id
                                                                                      value:interest.value
                                                                                   callback:^(id result) {
                                                                                       // NSLog(@"%@", result);
                                                                                   }];
                };
                
                QSection *section = [[QSection alloc] init];
                
                setInterestsToSection(lists, section, onChangeActivity);
                root.title = NSLocalizedString(@"Intereses de Actividades", @"");
                
                [root addSection:section];
                
            }
            callback(root);
        }];
    }
    else if ([mostrarCampos isEqualToString:@"ubicaciones"])
    {
        QRootElement *root = [[QRootElement alloc] init];
        root.grouped = YES;
        
        [[TZTriporgManager sharedManager] getLocationSpecificInterests:^(NSArray *lists) {
            
            if ([lists isKindOfClass:NSArray.class])
            {
                void(^onChangeLocation)(TZTreeFloatEntry *) = ^(TZTreeFloatEntry *entry) {
                    TZInterest *interest = entry.userInfo;
                    interest.value = @(entry.floatValue*4+1);
                    [[TZTriporgManager sharedManager] editLocationSpecificInterestsWithId:interest.id
                                                                                    value:interest.value
                                                                                 callback:^(id result) {
                                                                                     // NSLog(@"%@", result);
                                                                                 }];
                };
                
                QSection *section = [[QSection alloc] init];
                
                setInterestsToSection(lists, section, onChangeLocation);
                root.title = NSLocalizedString(@"Intereses de Ubicaciones", @"");
                
                [root addSection:section];
                
            }
            callback(root);
        }];
    }
}

- (void)lenguageChange:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    UIViewController *leng = [storyboard instantiateViewControllerWithIdentifier:@"LenguageShow"];
    
    [self.navigationController pushViewController:leng animated:YES];
}

- (void)passwordChange:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Verificar Cuenta", @"")
                          message:NSLocalizedString(@"Introduce tu contraseña actual", @"")
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancelar", @"")
                          otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    UITextField *passwordField = [alert textFieldAtIndex:0];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        passwordField.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    }
    
    passwordField.placeholder = @"Password";
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if (buttonIndex == 1)
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        if ([buttonTitle isEqualToString:NSLocalizedString(@"Hecho", @"")])
        {
            NSString *newPasswordText = [alertView textFieldAtIndex:0].text;
            NSString *againNewPasswordText = [alertView textFieldAtIndex:1].text;
            
            if ([newPasswordText isEqualToString:againNewPasswordText] && newPasswordText.length > 5)
            {
                [[TZTriporgManager sharedManager] changePasswordWithPassword:newPasswordText callback:^(id resul) {
                    
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:NSLocalizedString(@"Contraseña cambiada", @"")
                                          message:NSLocalizedString(@"Has cambiado tu contraseña satisfactoriamente.", @"")
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                          otherButtonTitles: nil, nil];
                    
                    [alert show];
                    
                }];
            }
            else
            {
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"Contraseñas no coinciden", @"")
                                      message:NSLocalizedString(@"La contraseña debe ser la misma en los dos campos y ser superior a 6 caracteres.", @"")
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                      otherButtonTitles: nil, nil];
                
                [alert show];
            }
        }
        else
        {
            NSString *emailText = [TZTriporgManager sharedManager].currentUser.email;
            NSString *passwordText = [alertView textFieldAtIndex:0].text;
            [[TZTriporgManager sharedManager] loginWithUser:emailText password:passwordText callback:^(id result) {
                if ([result isKindOfClass:[TZUser class]]) {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:NSLocalizedString(@"Cambiar Contraseña", @"")
                                          message:NSLocalizedString(@"Introduce la nueva contraseña", @"")
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancelar", @"")
                                          otherButtonTitles:NSLocalizedString(@"Hecho", @""), nil];
                    
                    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                    
                    UITextField *passField = [alert textFieldAtIndex:0];
                    passField.secureTextEntry = YES;
                    passField.placeholder = NSLocalizedString(@"Nueva Contraseña", @"");
                    UITextField *newPassField = [alert textFieldAtIndex:1];
                    newPassField.placeholder = NSLocalizedString(@"Confirmar Nueva Contraseña", @"");
                    
                    if ([versioniOS hasPrefix:@"6."])
                    {
                        
                    }
                    else
                    {
                        passField.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
                        newPassField.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
                    }
                    
                    [alert show];
                }
                else
                {
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:NSLocalizedString(@"Contraseña errónea", @"")
                                          message:NSLocalizedString(@"La contraseña que has introducido no es correcta.", @"")
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                          otherButtonTitles: nil, nil];
                    
                    [alert show];
                }
            }];
        }
    }
}

- (id)initWithCallback:(void(^)(TZUserProfileController *))callback
{
    [TZUserProfileController rootElement:self callback:^(QRootElement *root) {
        callback([self initWithRoot:root]);
    }];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *mostrarTitulos = [defaults objectForKey:@"codigoperfil"];
    
    if ([mostrarTitulos isEqualToString:@"perfil"])
    {
        //self.navigationItem.title = [TZTriporgManager sharedManager].currentUser.name;
        
        // Foto de Perfil
        UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
        [profileButton addTarget:self action:@selector(showMyActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        [profileButton.layer setCornerRadius:7.0f];
        [profileButton.layer setMasksToBounds:YES];
        profileImage = [[UIImage imageNamed:@"ProfileB"] tintImageWithColor:[UIColor lightGrayColor]];
        profileImageOn = NO;
        
        NSData *userImageData = [TZTriporgManager sharedManager].currentUser.downloadedImage;
        
        if (userImageData.length > 0)
        {
            profileImage = [UIImage imageWithData:userImageData];
            profileImageOn = YES;
        }
        
        [profileButton setImage:profileImage forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:profileButton];
    }
    
    if ([mostrarTitulos isEqualToString:@"generales"])
    {
        if ([versioniOS hasPrefix:@"6."])
        {
            
        }
        else
        {
            UIImageView *entertainmentColor = [[UIImageView alloc] init];
            entertainmentColor.backgroundColor = [UIColor colorWithString:@"#66167e"];
            entertainmentColor.alpha = 0.9;
            
            UIImageView *gastronomyColor = [[UIImageView alloc] init];
            gastronomyColor.backgroundColor = [UIColor colorWithString:@"#e7494a"];
            gastronomyColor.alpha = 0.9;
            
            UIImageView *conferencesColor = [[UIImageView alloc] init];
            conferencesColor.backgroundColor = [UIColor colorWithString:@"#ffb200"];
            conferencesColor.alpha = 0.9;
            
            UIImageView *sportsColor = [[UIImageView alloc] init];
            sportsColor.backgroundColor = [UIColor colorWithString:@"#00a7b7"];
            sportsColor.alpha = 0.9;
            
            UIImageView *celebrationColor = [[UIImageView alloc] init];
            celebrationColor.backgroundColor = [UIColor colorWithString:@"#e37327"];
            celebrationColor.alpha = 0.9;
            
            UIImageView *natureColor = [[UIImageView alloc] init];
            natureColor.backgroundColor = [UIColor colorWithString:@"#56be23"];
            natureColor.alpha = 0.9;
            
            UIImageView *cultureColor = [[UIImageView alloc] init];
            cultureColor.backgroundColor = [UIColor colorWithString:@"#54a9ea"];
            cultureColor.alpha = 0.9;
            
            UIImageView *othersColor = [[UIImageView alloc] init];
            othersColor.backgroundColor = [UIColor colorWithString:@"#979797"];
            othersColor.alpha = 0.9;
            
            UIImageView *monumentsColor = [[UIImageView alloc] init];
            monumentsColor.backgroundColor = [UIColor colorWithString:@"#374d94"];
            monumentsColor.alpha = 0.9;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                entertainmentColor.frame = CGRectMake(0, 35, 5, 60);
                gastronomyColor.frame = CGRectMake(0, 95, 5, 60);
                conferencesColor.frame = CGRectMake(0, 155, 5, 60);
                sportsColor.frame = CGRectMake(0, 215, 5, 60);
                celebrationColor.frame = CGRectMake(0, 275, 5, 60);
                natureColor.frame = CGRectMake(0, 335, 5, 60);
                cultureColor.frame = CGRectMake(0, 395, 5, 60);
                othersColor.frame = CGRectMake(0, 455, 5, 60);
                monumentsColor.frame = CGRectMake(0, 515, 5, 60);
            }
            else
            {
                entertainmentColor.frame = CGRectMake(0, 35, 5, 44);
                gastronomyColor.frame = CGRectMake(0, 79, 5, 44);
                conferencesColor.frame = CGRectMake(0, 123, 5, 44);
                sportsColor.frame = CGRectMake(0, 167, 5, 44);
                celebrationColor.frame = CGRectMake(0, 211, 5, 44);
                natureColor.frame = CGRectMake(0, 255, 5, 44);
                cultureColor.frame = CGRectMake(0, 299, 5, 44);
                othersColor.frame = CGRectMake(0, 343, 5, 44);
                monumentsColor.frame = CGRectMake(0, 387, 5, 44);
            }
            
            [self.view addSubview:entertainmentColor];
            [self.view addSubview:gastronomyColor];
            [self.view addSubview:conferencesColor];
            [self.view addSubview:sportsColor];
            [self.view addSubview:celebrationColor];
            [self.view addSubview:natureColor];
            [self.view addSubview:cultureColor];
            [self.view addSubview:othersColor];
            [self.view addSubview:monumentsColor];
        }
    }
    
    if ([versioniOS hasPrefix:@"6."])
    {
        self.quickDialogTableView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.quickDialogTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    self.quickDialogTableView.cellLayoutMarginsFollowReadableWidth = false;
    [self.quickDialogTableView reloadData];
}

- (void)showMyActionSheet:(id)sender
{
    if (profileImageOn == YES)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancelar", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Expandir", @""), NSLocalizedString(@"Subir Foto", @""), nil];
        
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancelar", @"")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Subir Foto", @""), nil];
        [actionSheet showInView:self.view];
    }
}

- (void)uploadPhotoWithPhoto:(UIImage *)photo
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
        UIButton *profileButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
        [profileButton addTarget:self action:@selector(showMyActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        [profileButton.layer setCornerRadius:7.0f];
        [profileButton.layer setMasksToBounds:YES];
        [profileButton setImage:photo forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:profileButton];
        
        [[TZTriporgManager sharedManager] uploadImageWithImage:photo callback:^(id response) {
            
            if ([response isKindOfClass:[NSError class]])
            {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                            message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                  otherButtonTitles:nil] show];
            }
            else
            {
                profileImage = photo;
                profileImageOn = YES;
                
                [self.quickDialogTableView reloadData];
            }
        }];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Expandir", @"")])
    {
        photoController = nil;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
        
        photoController = [storyboard instantiateViewControllerWithIdentifier:@"TriporgImageShow"];
        
        photoController.photoData = UIImagePNGRepresentation(profileImage);
        
        [self.navigationController pushViewController:photoController animated:YES];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Subir Foto", @"")])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            self.popover.delegate = self;
            [self.popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *imageDraw = nil;
    UIImage *tempImage = nil;
    CGSize targetSize;
    
    if (selectedImage.size.width > selectedImage.size.height)
    {
        targetSize = CGSizeMake(640,480);
    }
    else
    {
        targetSize = CGSizeMake(480,640);
    }
    
    imageDraw = [selectedImage imageByScalingAndCroppingForSize:targetSize];
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    [imageDraw drawInRect:thumbnailRect];
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self uploadPhotoWithPhoto:tempImage];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.popover dismissPopoverAnimated:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)  QEntryDidEndEditingElement:(QElement *)element andCell:(QEntryTableViewCell *)cell
{
    id value;
    
    if ([element isKindOfClass:[QDateTimeInlineElement class]]) {
        NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
        dateFromatter.dateFormat = @"yyyy-MM-dd";
        
        value = [dateFromatter stringFromDate:((QDateTimeInlineElement *)element).dateValue];
        
    } else if ([element isKindOfClass:[QRadioElement class]]) {
        value = ((QRadioElement *) element).selectedValue;
    } else if ([element isKindOfClass:[QEntryElement class]]) {
        value = ((QEntryElement *) element).textValue;
    } else if ([element isKindOfClass:[QFloatElement class]]) {
        value = [NSNumber numberWithFloat:((QFloatElement *) element).floatValue * 4.0f + 1.0f];
        
        if (((QFloatElement *)element).tag == -2) {
            [[TZTriporgManager sharedManager] editGeneralInterestId:((QFloatElement *)element).userInfo value:value callback:^(id response) {
                if ([response isKindOfClass:[NSError class]])
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                      otherButtonTitles:nil] show];
                }
            }];
            return;
        }
    }
    
    @try {
        
        
    }
    @catch (NSException *exception) {
        
    }
    
    if ([element.key isEqualToString:@"name"] && [value isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                    message:NSLocalizedString(@"Por favor, rellene el nombre", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                          otherButtonTitles:nil] show];
        
        return;
    }
    else if ([element.key isEqualToString:@"surname"] && [value isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                    message:NSLocalizedString(@"Por favor, rellene el apellido", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                          otherButtonTitles:nil] show];
        
        return;
    }
    else if ([element.key isEqualToString:@"nickname"] && [value isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                    message:NSLocalizedString(@"Por favor, rellene el usuario", @"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    [[TZTriporgManager sharedManager] editUserProfileKey:element.key value:value callback:^(id response) {
        if ([response isKindOfClass:[NSError class]])
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                        message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
        }
    }];
}

- (void)activityInt:(id)sender
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *mostrarPerfil;
        mostrarPerfil = @"actividades";
        [defaults setObject:mostrarPerfil forKey:@"codigoperfil"];
        [defaults synchronize];
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        [self performSelector:@selector(goToTheUserPanel:) withObject:nil];
    }
}

- (void)locationInt:(id)sender
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *mostrarPerfil;
        mostrarPerfil = @"ubicaciones";
        [defaults setObject:mostrarPerfil forKey:@"codigoperfil"];
        [defaults synchronize];
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        [self performSelector:@selector(goToTheUserPanel:) withObject:nil];
    }
}

- (void)goToTheUserPanel:(id)sender
{
    [[TZUserProfileController alloc] initWithCallback:^(TZUserProfileController *userProfile) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [self.navigationController pushViewController:userProfile animated:YES];
    }];
}

@end
