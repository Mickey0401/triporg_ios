//
//  TZSuggestionViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 27/01/14.
//
//

#import "TZSuggestionViewController.h"
#import "UIColor+String.h"
#import "TZTriporgManager.h"
#import "MBProgressHUD.h"

@interface TZSuggestionViewController () {
    NSString *messageString;
    UITextView *messageTextView;
    UILabel *messageLabel;
}

@end

@implementation TZSuggestionViewController

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
    
    self.title = NSLocalizedString(@"Sugerencias", @"");
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Hecho", @"") style:UIBarButtonItemStyleDone target:self action:@selector(SendSuggestionToTriporg:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            //"iphone4"
            messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, self.view.bounds.size.width, 40)];
            messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 120, self.view.bounds.size.width - 20, 120)];
        }
        if (result.height == 568)
        {
            //"iphone5"
            messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, self.view.bounds.size.width, 40)];
            messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 120, self.view.bounds.size.width - 20, 210)];
        }
    }
    else {
        //"iPad"
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 75, 768, 40)];
        messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(138, 120, 768 - 20, 270)];
    }
    
    // iOS Version
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    messageLabel.text = NSLocalizedString(@"Ayúdanos a mejorar", "");
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = [UIColor grayColor];
    messageLabel.backgroundColor = [UIColor clearColor];
    
    messageTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    messageTextView.layer.borderWidth = 0.3;
    messageTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    [messageTextView.layer setCornerRadius:6.0f];
    [messageTextView.layer setMasksToBounds:YES];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        self.view.backgroundColor = [UIColor colorWithString:@"#eeeeee"];
        
        CGRect frame = messageLabel.frame;
        frame.origin.y -= 60;
        messageLabel.frame = frame;
        
        frame = messageTextView.frame;
        frame.origin.y -= 60;
        messageTextView.frame = frame;
        
    }
    else
    {
        messageTextView.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    }
    
    messageTextView.delegate = self;
    
    [self.view addSubview:messageLabel];
    [self.view addSubview:messageTextView];
    
    [self performSelector:@selector(activateTextView:) withObject:nil afterDelay:0.2];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 3)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (textView.text.length > 2200)
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)SendSuggestionToTriporg:(id)sender
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
        messageString = messageTextView.text;
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        [self performSelector:@selector(completeSuggestion:) withObject:nil afterDelay:1];
        
        [[TZTriporgManager sharedManager] sendSuggestion:messageString callback:^(id result) {
            
        }];
    }
}

- (void)completeSuggestion:(id)sender
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
    
    messageTextView.text = @"";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"¡Sugerencia enviada!", @"");
    
    [HUD show:NO];
    [HUD hide:YES afterDelay:1.5];
    
    [self performSelector:@selector(finishSuggestion:) withObject:nil afterDelay:2];
    
}

- (void)finishSuggestion:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)activateTextView:(id)sender
{
    [messageTextView becomeFirstResponder];
}


@end
