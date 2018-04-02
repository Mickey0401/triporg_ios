//
//  TZLegalViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 21/08/13.
//
//

#import "TZLegalViewController.h"
#import "UIColor+String.h"

@interface TZLegalViewController ()

@end

@implementation TZLegalViewController

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
    
    self.title = NSLocalizedString(@"Legal", @"");
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Volver", @"") style:UIBarButtonItemStylePlain target:self action:@selector(backToLogin:)];
    
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        self.view.backgroundColor = [UIColor colorWithString:@"#eeeeee"];
    }
    else
    {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** Cierra los terminos y condiciones y vuelve al LoginViewController */
- (void)backToLogin:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
