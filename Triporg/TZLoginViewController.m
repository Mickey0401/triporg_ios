//
//  TZLoginViewController.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZLoginViewController.h"
#import "TZTriporgManager.h"
#import "TZUser.h"
#import "TZCheckUser.h"
#import "MBProgressHUD.h"
#import "UIImage+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>


// Google Plus ID Client
static NSString *const kClientId = @"426746590305.apps.googleusercontent.com";

@interface TZLoginViewController () {
    GPPSignIn *signIn;
    UIButton *enterEmailButton;
    UIButton *automaticUserButton;
    UIButton *advanceButton;
    UIButton *forgotPasswordButton;
    UIImageView *logoImageView;
    UITextField *userTextField;
    UITextField *passwordTextField;
    UISwitch *aceptSwitch;
    UILabel *mustAcceptLabel;
    NSString *versioniOS;
    NSInteger preparedForEnter;
    BOOL userHasAccepted;
}

@end

@implementation TZLoginViewController

@synthesize copyrightTriporg, returnButton, legalButton, googleLogin, facebookLogin;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Toolbar Set Up
    
    returnButton.title = NSLocalizedString(@"Volver", @"");
    returnButton.enabled = NO;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger year = [components year];
    copyrightTriporg.title = [NSString stringWithFormat:@"Triporg © %d",year];
    legalButton.title = NSLocalizedString(@"Legal", @"");
    
    // Facebook Login Button Set Up
    
    facebookLogin = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes", @"user_birthday", @"user_location", @"user_hometown"]];
    facebookLogin.delegate = self;
    facebookLogin.backgroundColor = [UIColor clearColor];
    
    // Google Plus Login Set Up
    
    googleLogin = [[GPPSignInButton alloc] init];
    
    signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin, // defined in GTLPlusConstants.h
                     nil];
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
    
    [googleLogin.layer setCornerRadius:7.0f];
    [googleLogin.layer setMasksToBounds:YES];
    googleLogin.backgroundColor = [UIColor clearColor];
    googleLogin.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //[signIn trySilentAuthentication];
    
    // Set up the interface based on the device
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            // iphone3GS, iphone4, iphone4S
            logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 97)];
            userTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 130, self.view.bounds.size.width - 40, 30)];
            passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 168, self.view.bounds.size.width - 40, 30)];
            advanceButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 206, self.view.bounds.size.width - 40, 48)];
            forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 262, self.view.bounds.size.width - 40, 30)];
            mustAcceptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 262, self.view.bounds.size.width - 40, 60)];
            aceptSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(136, 330, 51, 31)];
            googleLogin.frame = CGRectMake(20, self.view.bounds.size.height - 155, self.view.bounds.size.width - 40, 30);
            enterEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 100, googleLogin.frame.size.width, googleLogin.frame.size.height)];
            automaticUserButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 265, googleLogin.frame.size.width, googleLogin.frame.size.height)];
            facebookLogin.frame = CGRectMake(20, self.view.bounds.size.height - 207, self.view.bounds.size.width - 40, 45);
        }
        if (result.height == 568)
        {
            // iphone5, iphone5C, iphone5S
            logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 185)];
            userTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 218, self.view.bounds.size.width - 40, 30)];
            passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 256, self.view.bounds.size.width - 40, 30)];
            advanceButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 294, self.view.bounds.size.width - 40, 48)];
            forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 352, self.view.bounds.size.width - 40, 30)];
            mustAcceptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 350, self.view.bounds.size.width - 40, 60)];
            aceptSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(136, 418, 51, 31)];
            googleLogin.frame = CGRectMake(20, self.view.bounds.size.height - 155, self.view.bounds.size.width - 40, 30);
            enterEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 100, googleLogin.frame.size.width, googleLogin.frame.size.height)];
            automaticUserButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.bounds.size.height - 265, googleLogin.frame.size.width, googleLogin.frame.size.height)];
            facebookLogin.frame = CGRectMake(20, self.view.bounds.size.height - 207, self.view.bounds.size.width - 40, 45);
        }
    }
    else
    {
        // iPad, iPad Air
        logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 768 - 256, 250)];
        userTextField = [[UITextField alloc] initWithFrame:CGRectMake(500, 200, 768 - 266, 40)];
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(500, 250, 768 - 266, 40)];
        advanceButton = [[UIButton alloc] initWithFrame:CGRectMake(500, 300, 768 - 266, 48)];
        forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(500, 360, 768 - 266, 30)];
        mustAcceptLabel = [[UILabel alloc] initWithFrame:CGRectMake(500, 380, 768 - 266, 60)];
        aceptSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(735, 440, 51, 31)];
        googleLogin.frame = CGRectMake(500, 291, 768 - 266, 30);
        enterEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(500, 350, googleLogin.frame.size.width, googleLogin.frame.size.height)];
        automaticUserButton = [[UIButton alloc] initWithFrame:CGRectMake(500, 173, googleLogin.frame.size.width, googleLogin.frame.size.height)];
        facebookLogin.frame = CGRectMake(500, 235, 768 - 266, 45);
    }
    
    // iOS Version
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        userTextField.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
        passwordTextField.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
        returnButton.tintColor = [UIColor clearColor];
    }
    
    logoImageView.image = [UIImage imageNamed:@"TriporgTitle"];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    userTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [userTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    userTextField.backgroundColor = [UIColor whiteColor];
    userTextField.borderStyle = UITextBorderStyleRoundedRect;
    userTextField.placeholder = @"Email";
    userTextField.delegate = self;
    
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.placeholder = @"Password";
    passwordTextField.delegate = self;
    
    advanceButton.backgroundColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    [advanceButton setTitle:NSLocalizedString(@"Continuar", @"") forState:UIControlStateNormal];
    [advanceButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [advanceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [advanceButton addTarget:self action:@selector(checkUserAction:) forControlEvents:UIControlEventTouchUpInside];
    [advanceButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [advanceButton.layer setCornerRadius:3.0f];
    [advanceButton.layer setMasksToBounds:YES];
    advanceButton.userInteractionEnabled = YES;
    
    forgotPasswordButton.backgroundColor = [UIColor clearColor];
    [forgotPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgotPasswordButton setTitle:NSLocalizedString(@"¿Has olvidado la contraseña?", @"") forState:UIControlStateNormal];
    [forgotPasswordButton addTarget:self action:@selector(forgotPassEmail:) forControlEvents:UIControlEventTouchUpInside];
    
    aceptSwitch.on = YES;
    [aceptSwitch addTarget:self action:@selector(aceptar:) forControlEvents:UIControlEventValueChanged];
    
    mustAcceptLabel.textColor = [UIColor whiteColor];
    mustAcceptLabel.numberOfLines = 2;
    mustAcceptLabel.textAlignment = NSTextAlignmentCenter;
    mustAcceptLabel.backgroundColor = [UIColor clearColor];
    mustAcceptLabel.text = NSLocalizedString(@"He leido y acepto la política de privacidad y condiciones de uso", @"");
    
    enterEmailButton.backgroundColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    [enterEmailButton addTarget:self action:@selector(showEmailField:) forControlEvents:UIControlEventTouchUpInside];
    [enterEmailButton setTitle:NSLocalizedString(@"Entrar con Email", @"") forState:UIControlStateNormal];
    [enterEmailButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [enterEmailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterEmailButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [enterEmailButton.layer setCornerRadius:3.0f];
    [enterEmailButton.layer setMasksToBounds:YES];
    advanceButton.userInteractionEnabled = YES;
    
    automaticUserButton.backgroundColor = [UIColor darkGrayColor];
    [automaticUserButton addTarget:self action:@selector(enterWithAutomaticUser:) forControlEvents:UIControlEventTouchUpInside];
    [automaticUserButton setTitle:NSLocalizedString(@"Probar sin registrarme", @"") forState:UIControlStateNormal];
    [automaticUserButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [automaticUserButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [automaticUserButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [automaticUserButton.layer setCornerRadius:3.0f];
    [automaticUserButton.layer setMasksToBounds:YES];
    automaticUserButton.userInteractionEnabled = YES;
    
    UIImageView *imageEmail = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 35, googleLogin.bounds.size.height)];
    imageEmail.contentMode = UIViewContentModeScaleAspectFit;
    imageEmail.image = [[UIImage imageNamed:@"email"] tintImageWithColor:[UIColor whiteColor]];
    [enterEmailButton addSubview:imageEmail];
    
    UIImageView *imageAutomatic = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 35, googleLogin.bounds.size.height)];
    imageAutomatic.contentMode = UIViewContentModeScaleAspectFit;
    
    imageAutomatic.image = [[UIImage imageNamed:@"TriporgWhite"] tintImageWithColor:[UIColor whiteColor]];
    [automaticUserButton addSubview:imageAutomatic];
    
    UIColor *colorSeparator = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"CellHeaderBackground"] tintImageWithColor:[UIColor whiteColor]]];
    
    UIImageView *separatorLineEmail = [[UIImageView alloc] initWithFrame:CGRectMake(42.5, 0, 1, googleLogin.bounds.size.height)];
    separatorLineEmail.backgroundColor = colorSeparator;
    separatorLineEmail.alpha = 0.6;
    [enterEmailButton addSubview:separatorLineEmail];
    
    UIImageView *separatorLineFB = [[UIImageView alloc] initWithFrame:CGRectMake(42.5, 0, 1, facebookLogin.bounds.size.height)];
    separatorLineFB.backgroundColor = colorSeparator;
    separatorLineFB.alpha = 0.6;
    [facebookLogin addSubview:separatorLineFB];
    
    UIImageView *separatorLineGPlus = [[UIImageView alloc] initWithFrame:CGRectMake(42.5, 2, 1, googleLogin.bounds.size.height-4)];
    separatorLineGPlus.backgroundColor = colorSeparator;
    separatorLineGPlus.alpha = 0.6;
    [googleLogin addSubview:separatorLineGPlus];
    
    UIImageView *separatorLineAutomatic = [[UIImageView alloc] initWithFrame:CGRectMake(42.5, 0, 1, automaticUserButton.bounds.size.height)];
    separatorLineAutomatic.backgroundColor = colorSeparator;
    separatorLineAutomatic.alpha = 0.6;
    [automaticUserButton addSubview:separatorLineAutomatic];
    
    [self.view addSubview:logoImageView];
    [self.view addSubview:userTextField];
    [self.view addSubview:passwordTextField];
    [self.view addSubview:advanceButton];
    [self.view addSubview:forgotPasswordButton];
    [self.view addSubview:mustAcceptLabel];
    [self.view addSubview:aceptSwitch];
    [self.view addSubview:facebookLogin];
    [self.view addSubview:googleLogin];
    [self.view addSubview:enterEmailButton];
    [self.view addSubview:automaticUserButton];
    
    userHasAccepted = YES;
    preparedForEnter = 0;
    
    userTextField.hidden = YES;
    passwordTextField.hidden = YES;
    advanceButton.hidden = YES;
    forgotPasswordButton.hidden = YES;
    mustAcceptLabel.hidden = YES;
    aceptSwitch.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/** Muestra el textField para insertar tu email */
- (void)showEmailField:(id)sender
{
    returnButton.enabled = YES;
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        returnButton.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    }
    
    advanceButton.hidden = NO;
    userTextField.hidden = NO;
    enterEmailButton.hidden = YES;
    automaticUserButton.hidden = YES;
    googleLogin.hidden = YES;
    facebookLogin.hidden = YES;
    
    userTextField.text = @"";
    passwordTextField.text = @"";
    
    [UIView transitionWithView:logoImageView duration:0.4
                       options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                           
                       } completion:^(BOOL finished) {
                           [userTextField becomeFirstResponder];
                       }];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.30];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [[enterEmailButton layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[automaticUserButton layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[googleLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[facebookLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[advanceButton layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[userTextField layer] addAnimation:animation forKey:@"SwitchToView1"];
}

/** Comprueba que el usuario este en la base de datos, en caso afirmativo muestra campo password para iniciar el logeo, sino, abre el campo de registro */
- (void)checkUserAction:(id)sender
{
    NSString *email = userTextField.text;
    
    if ([self validateEmail:[userTextField text]] == 1)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[TZTriporgManager sharedManager] checkUser:email callback:^(id result) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if ([result isKindOfClass:[NSError class]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                                message:[((NSError *) result).userInfo objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if ([result isEqualToString:@"true"])
            {
                preparedForEnter = 1;
                
                [advanceButton setTitle:NSLocalizedString(@"Entrar", @"") forState:UIControlStateNormal];
                [advanceButton removeTarget:self action:@selector(checkUserAction:) forControlEvents:UIControlEventTouchUpInside];
                [advanceButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
                
                passwordTextField.hidden = NO;
                forgotPasswordButton.hidden = NO;
                
                [UIView transitionWithView:logoImageView duration:0.4
                                   options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                                       [passwordTextField becomeFirstResponder];
                                   } completion:nil];
                
                [UIView transitionWithView:advanceButton duration:0.4
                                   options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                                       
                                   } completion:nil];
                
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.30];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromRight];
                [[passwordTextField layer] addAnimation:animation forKey:@"SwitchToView1"];
                [[googleLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
                [[facebookLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
                [[forgotPasswordButton layer] addAnimation:animation forKey:@"SwitchToView1"];
                
                googleLogin.hidden = YES;
                facebookLogin.hidden = YES;
            }
            else if ([result isEqualToString:@"false"])
            {
                preparedForEnter = 2;
                
                mustAcceptLabel.hidden = NO;
                aceptSwitch.hidden = NO;
                
                [userTextField resignFirstResponder];
                
                [advanceButton setTitle:NSLocalizedString(@"Registrarse", @"") forState:UIControlStateNormal];
                [advanceButton removeTarget:self action:@selector(checkUserAction:) forControlEvents:UIControlEventTouchUpInside];
                [advanceButton addTarget:self action:@selector(registerTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                [UIView transitionWithView:logoImageView duration:0.4
                                   options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                                       
                                   } completion:nil];
                
                [UIView transitionWithView:advanceButton duration:0.4
                                   options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                                       
                                   } completion:nil];
                
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.30];
                [animation setType:kCATransitionPush];
                [animation setSubtype:kCATransitionFromRight];
                [[aceptSwitch layer] addAnimation:animation forKey:@"SwitchToView1"];
                [[mustAcceptLabel layer] addAnimation:animation forKey:@"SwitchToView1"];
                [[googleLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
                [[facebookLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
                
                googleLogin.hidden = YES;
                facebookLogin.hidden = YES;
            }
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"") message:NSLocalizedString(@"Introduce un email válido", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];
        [alert show];
    }
}

/** Logea al usuario y lo introduce en Triporg si la contraseña coincide con el email  */
- (void)login:(id)sender
{
    NSString *user = userTextField.text;
    NSString *pass = passwordTextField.text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TZTriporgManager sharedManager] loginWithUser:user password:pass callback:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([result isKindOfClass:[TZUser class]])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([result isKindOfClass:[NSError class]])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                            message:[((NSError *) result).userInfo objectForKey:@"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

/** Abre las condiciones y terminos de uso de Triporg  */
- (IBAction)legal:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    UIViewController *legalViewController = [storyboard instantiateViewControllerWithIdentifier:@"LegalShow"];
    UINavigationController *legalNavController = [[UINavigationController alloc] initWithRootViewController:legalViewController];
    
    [self presentViewController:legalNavController animated:YES completion:nil];
}

/** Registra al usuario con el email que se ha introducido  */
- (void)registerTapped:(id)sender
{
    if ([self validateEmail:[userTextField text]] == 1)
    {
        if (userHasAccepted == YES)
        {
            NSString *username = userTextField.text;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [[TZTriporgManager sharedManager] validateEmail:username callback:^(id result) {
                
                if ([result isKindOfClass:[NSError class]])
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                                message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                      otherButtonTitles:nil] show];
                }
                else if ([result isEqualToString:@"true"])
                {
                    [[TZTriporgManager sharedManager] registration:username callback:^(id result) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        
                        if ([result isKindOfClass:[NSError class]])
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                                            message:[((NSError *) result).userInfo objectForKey:@"error"]
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                        else
                        {
                            preparedForEnter = 1;
                            passwordTextField.hidden = NO;
                            forgotPasswordButton.hidden = NO;
                            mustAcceptLabel.hidden = YES;
                            aceptSwitch.hidden = YES;
                            advanceButton.hidden = NO;
                            googleLogin.hidden = YES;
                            facebookLogin.hidden = YES;
                            
                            [advanceButton setTitle:NSLocalizedString(@"Entrar", @"") forState:UIControlStateNormal];
                            [advanceButton removeTarget:self action:@selector(registerTapped:) forControlEvents:UIControlEventTouchUpInside];
                            [advanceButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [UIView transitionWithView:logoImageView duration:0.4
                                               options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                                                   
                                               } completion:nil];
                            
                            CATransition *animation = [CATransition animation];
                            [animation setDuration:0.30];
                            [animation setType:kCATransitionPush];
                            [animation setSubtype:kCATransitionFromRight];
                            [[advanceButton layer] addAnimation:animation forKey:@"SwitchToView1"];
                            [[passwordTextField layer] addAnimation:animation forKey:@"SwitchToView1"];
                            [[forgotPasswordButton layer] addAnimation:animation forKey:@"SwitchToView1"];
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Entra y disfruta de Triporg", @"")
                                                                            message:NSLocalizedString(@"Se ha enviado un email a tu cuenta de correo electrónico, con tu usuario y contraseña. Entra y disfruta de todas las bondades de Triporg.", @"")
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                    
                }
                else if ([result isEqualToString:@"false"])
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"") message:NSLocalizedString(@"Introduce un email válido", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];
                    [alert show];
                }
            }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                            message:NSLocalizedString(@"Debes aceptar la política de privacidad y las condiciones de uso", @"")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"") message:NSLocalizedString(@"Introduce un email válido", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @"Ok"), nil];
        [alert show];
    }
}

/** Oculta el teclado cuando se toca en alguna parte de la pantalla que no sea el textField  */
- (IBAction)outsideTap:(id)sender
{
    [userTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

- (void)enterWithAutomaticUser:(id)sender
{
    [[TZTriporgManager sharedManager] loginWithoutUser:^(id resp) {
        
        if ([resp isKindOfClass:[TZUser class]])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else if ([resp isKindOfClass:[NSError class]])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                            message:[((NSError *) resp).userInfo objectForKey:@"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }];
}

#pragma mark Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.returnKeyType = (textField == userTextField && passwordTextField.text.length == 0)
    || (textField == passwordTextField && userTextField.text.length == 0)  ? UIReturnKeyNext : UIReturnKeyDone;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    switch (preparedForEnter)
    {
        case 0:
            [self checkUserAction:nil];
            break;
        case 1:
            if (userTextField.text.length == 0)
                [userTextField becomeFirstResponder];
            else if (passwordTextField.text.length == 0)
                [passwordTextField becomeFirstResponder];
            else
                [self login:nil];
            break;
        case 2:
            
            break;
    }
    return NO;
}

/** Retorna todas las acciones a la posición inicial del LoginViewController  */
- (IBAction)backToNormal:(id)sender
{
    preparedForEnter = 0;
    passwordTextField.hidden = YES;
    advanceButton.hidden = YES;
    forgotPasswordButton.hidden = YES;
    returnButton.enabled = NO;
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        returnButton.tintColor = [UIColor clearColor];
    }
    
    mustAcceptLabel.hidden = YES;
    aceptSwitch.hidden = YES;
    googleLogin.hidden = NO;
    facebookLogin.hidden = NO;
    enterEmailButton.hidden = NO;
    automaticUserButton.hidden = NO;
    userTextField.hidden = YES;
    
    [advanceButton setTitle:NSLocalizedString(@"Continuar", @"") forState:UIControlStateNormal];
    [advanceButton removeTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [advanceButton removeTarget:self action:@selector(registerTapped:) forControlEvents:UIControlEventTouchUpInside];
    [advanceButton addTarget:self action:@selector(checkUserAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView transitionWithView:logoImageView duration:0.4
                       options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           
                       } completion:nil];
    
    [UIView transitionWithView:advanceButton duration:0.4
                       options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
                           
                       } completion:nil];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.30];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [[googleLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[facebookLogin layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[advanceButton layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[forgotPasswordButton layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[enterEmailButton layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[automaticUserButton layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[aceptSwitch layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[mustAcceptLabel layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[userTextField layer] addAnimation:animation forKey:@"SwitchToView1"];
    [[passwordTextField layer] addAnimation:animation forKey:@"SwitchToView1"];
}

/** Funcion que determina si un email es valido  */
- (BOOL)validateEmail:(NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

/** Envia un email para el usuario que ha olvidado su contraseña */
- (void)forgotPassEmail:(id)sender
{
    NSString *email = userTextField.text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TZTriporgManager sharedManager] forgotPasswordWithEmail:email callback:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([result isKindOfClass:[NSError class]])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                            message:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Se ha enviado un email a %@ donde podrás recuperar tu contraseña.", @""), email]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

/** Controla que el usuario haya aceptado las condiciones de usos */
- (void)aceptar:(id)sender
{
    if (userHasAccepted == NO)
    {
        userHasAccepted = YES;
    }
    else
    {
        userHasAccepted = NO;
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (error)
    {
        // Haz algún error de control aquí.
    }
    else
    {
        //[self refreshInterfaceBasedOnSignIn];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        GTLServicePlus *plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error)
                    {
                        GTMLoggerError(@"Error: %@", error);
                    }
                    else
                    {
                        NSString *googleID = person.identifier;
                        NSString *email = signIn.authentication.userEmail;
                        NSString *name = person.name.givenName;
                        
                        if (name.length == 0)
                        {
                            name = NSLocalizedString(@"Nombre", @"");
                        }
                        
                        NSString *surname = person.name.familyName;
                        
                        if (surname.length == 0)
                        {
                            name = NSLocalizedString(@"Apellidos", @"");
                        }
                        
                        NSString *gender = person.gender;
                        
                        if (gender.length == 0)
                        {
                            gender = @"M";
                        }
                        else
                        {
                            if ([gender isEqualToString:@"male"])
                            {
                                gender = @"M";
                            }
                            else
                            {
                                gender = @"F";
                            }
                        }
                        
                        NSString *lenguage = person.language;
                        
                        if (lenguage.length == 0)
                        {
                            lenguage = @"es";
                        }
                        
                        NSArray *cityArray = person.placesLived;
                        GTLPlusPersonPlacesLivedItem *googleItem = nil;
                        NSString *city;
                        
                        if (cityArray.count > 0)
                        {
                            googleItem = [cityArray objectAtIndex:0];
                            city = googleItem.value;
                        }
                        else
                        {
                            city = @"Mata-Utu";
                        }
                        
                        NSNumber *age = person.ageRange.min;
                        NSString *yearString;
                        if (age == nil)
                        {
                            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
                            NSInteger actualYear = [components year];
                            NSInteger yearForBornUser = 1905;
                            NSInteger ageForReplace = actualYear - yearForBornUser;
                            
                            age = [NSNumber numberWithInteger:ageForReplace];
                        }
                        
                        yearString = [NSString stringWithFormat:@"%@",age];
                        
                        NSString *imageUrl = person.image.url;
                        
                        if (imageUrl.length == 0)
                        {
                            imageUrl = @"NOPHOTO";
                        }
                        
                        imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"?sz=50" withString:@""];
                        
                        [[TZTriporgManager sharedManager] loginWithGoogleOrFacebook:email name:name surname:surname gender:gender image:imageUrl city:city years:yearString lang:lenguage googleID:googleID facebookID:nil callback:^(id resp) {
                            
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            
                            if ([resp isKindOfClass:[TZUser class]])
                            {
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }
                            else if ([resp isKindOfClass:[NSError class]])
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                                                message:[((NSError *) resp).userInfo objectForKey:@"error"]
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

- (void)refreshInterfaceBasedOnSignIn
{
    if ([[GPPSignIn sharedInstance] authentication])
    {
        // The user is signed in.
        self.googleLogin.hidden = YES;
        // Perform other actions here, such as showing a sign-out button
    }
    else
    {
        self.googleLogin.hidden = NO;
        // Perform other actions here
    }
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    NSURL *smallResPicURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", user.id]];
    NSLog(@"%@", smallResPicURL);
    
    //start Fetching Data...
    [FBRequestConnection startWithGraphPath:@"me" parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"id, first_name, last_name, email, picture.width(720).heigth(720)", @"fields", nil] HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        NSDictionary *userData = (NSDictionary *) result;
        NSLog(@"%@", [userData description]);
        
        id picture = result[@"picture"];
        id data = picture[@"data"];
        //id url = data[@"url"];
        
        
        NSString *email = [user objectForKey:@"email"];
        NSString *name = [user objectForKey:@"first_name"];
        //NSString *name = [user objectForKey:@"name"];
        NSString *lastName = [user objectForKey:@"last_name"];
        NSString *birthdate = [user objectForKey:@"birthday"];
        NSString *locale = [user objectForKey:@"locale"];
        NSString *gender = [user objectForKey:@"gender"];
        NSString *facebokID = [user objectForKey:@"id"];
        NSString *city = [[user objectForKey:@"location"] objectForKey:@"name"];
        
        //added
        email = [userData objectForKey:@"email"];
        name = [userData objectForKey:@"first_name"];
        lastName = [userData objectForKey:@"last_name"];
        
        NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", facebokID];
        
        if (city.length == 0)
        {
            city = @"Mata-Utu";
        }
        else
        {
            NSRange range = [city rangeOfString:@","];
            city = [city substringToIndex:range.location];
        }
        
        NSString *birdthdateFinal;
        
        if (birthdate.length > 1)
        {
            NSArray *birthdateArray = [birthdate componentsSeparatedByString:@"/"];
            NSString *day = [birthdateArray objectAtIndex:0];
            NSString *month = [birthdateArray objectAtIndex:1];
            NSString *year = [birthdateArray objectAtIndex:2];
            
            birdthdateFinal = [NSString stringWithFormat:@"%@-%@-%@", year , month, day];
        }
        else
        {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
            NSInteger actualYear = [components year];
            NSInteger yearForBornUser = 1905;
            NSInteger ageForReplace = actualYear - yearForBornUser;
            
            birdthdateFinal = [NSString stringWithFormat:@"%d", ageForReplace];
        }
        
        if (locale.length > 1)
        {
            NSRange rangeL = [locale rangeOfString:@"_"];
            locale = [locale substringToIndex:rangeL.location];
        }
        else
        {
            locale = @"en";
        }
        
        if (gender.length == 0)
        {
            gender = @"M";
        }
        else
        {
            if ([gender isEqualToString:@"male"])
            {
                gender = @"M";
            }
            else
            {
                gender = @"F";
            }
        }
        
        [[TZTriporgManager sharedManager] loginWithGoogleOrFacebook:email name:name surname:lastName gender:gender image:imageUrl city:city years:birdthdateFinal lang:locale googleID:nil facebookID:facebokID callback:^(id resp) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if ([resp isKindOfClass:[TZUser class]])
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else if ([resp isKindOfClass:[NSError class]])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                                message:[((NSError *) resp).userInfo objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }];
    
    
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error])
    {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    }
    else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
    {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    }
    else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
    {
        //NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    }
    else
    {
        alertTitle = @"Something went wrong";
        alertMessage = @"Please try again later.";
        //NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage)
    {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                          otherButtonTitles:nil] show];
    }
}

@end
