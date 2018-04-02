//
//  TZBookingViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 19/03/14.
//
//

#import "TZBookingViewController.h"
#import "MBProgressHUD.h"

@interface TZBookingViewController ()

@end

@implementation TZBookingViewController

@synthesize webView;

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
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Reservas", @"");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadBooking:)];
    
    webView.scalesPageToFit = YES;
    webView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    NSString *urlString = @"http://m.booking.com?aid=381582";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                      otherButtonTitles:nil] show];
}

/** Recarga el contenido del webView */
- (void)reloadBooking:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [webView reload];
}


@end
