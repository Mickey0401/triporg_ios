//
//  TZAboutViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 10/07/13.
//
//

#import "TZAboutViewController.h"
#import "UIImage+Additions.h"
#import <QuartzCore/QuartzCore.h>

@interface TZAboutViewController ()

@end

@implementation TZAboutViewController

@synthesize versionApp,copyrightT,webButton, logoAbout ,textoAtribuciones;


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
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger year = [components year];
    copyrightT.text = [NSString stringWithFormat:@"Triporg © %d",year];
    copyrightT.backgroundColor = [UIColor clearColor];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    self.title = NSLocalizedString(@"Acerca de", @"");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGFloat viewWidth = 768.0;
        
        versionApp.hidden = YES;
        copyrightT.hidden = YES;
        webButton.hidden = YES;
        textoAtribuciones.hidden = YES;
        logoAbout.hidden = YES;
        
        UIImageView *logoIpad = [[UIImageView alloc] initWithFrame:CGRectMake(128, 50, viewWidth, 200)];
        logoIpad.image = [UIImage imageNamed:@"TriporgTitle"];
        logoIpad.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:logoIpad];
        
        UILabel *ipadVersion = [[UILabel alloc] initWithFrame:CGRectMake(128, 250, viewWidth, 40)];
        ipadVersion.textAlignment = NSTextAlignmentCenter;
        ipadVersion.text = [NSString stringWithFormat:@"Version %@",version];
        ipadVersion.textColor = [UIColor whiteColor];
        ipadVersion.font = [UIFont fontWithName:@"HelveticaNeue" size:27];
        ipadVersion.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:ipadVersion];
        
        UILabel *copyrightiPad = [[UILabel alloc] initWithFrame:CGRectMake(128, 340, viewWidth, 40)];
        copyrightiPad.textAlignment = NSTextAlignmentCenter;
        copyrightiPad.text = [NSString stringWithFormat:@"Triporg © %d",year];
        copyrightiPad.textColor = [UIColor whiteColor];
        copyrightiPad.backgroundColor = [UIColor clearColor];
        copyrightiPad.font = [UIFont fontWithName:@"HelveticaNeue" size:27];
        
        [self.view addSubview:copyrightiPad];
        
        UITextView *textoIpad = [[UITextView alloc] initWithFrame:CGRectMake(178, 490, viewWidth - 100, 250)];
        textoIpad.text = @"Pencil designed by Chris Lee from The Noun Project, Map designed by Atelier Iceberg from The Noun Project, Map Marker designed by Dennis Gramms from The Noun Project,Trash Can designed by Björn Wisnewski from The Noun Project, Magnifying Glass designed by John Caserta from The Noun Project, Star designed by Renee Ramsey-Passmore from The Noun Project, Circle designed by Luboš Volkov from The Noun Project, Graph designed by Erin Standley from The Noun Project, Electronic Payment designed by Lance Weisser from The Noun Project, Money designed by Sergey Shmidt from The Noun Project, Delete & Check Mark & Cloud Download designed by P.J. Onori from The Noun Project, Save designed by Alex Dee from The Noun Project, City designed by Thibault Geffroy from The Noun Project, Loading designed by Mateo Zlatar from The Noun Project.";
        
        textoIpad.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        textoIpad.textAlignment = NSTextAlignmentJustified;
        textoIpad.editable = NO;
        textoIpad.backgroundColor = [UIColor clearColor];
        textoIpad.textColor = [UIColor whiteColor];
        
        [self.view addSubview:textoIpad];
        
        UIButton *webIpad = [[UIButton alloc] initWithFrame:CGRectMake(178, 400, viewWidth - 100, 40)];
        [webIpad addTarget:self action:@selector(webIr:) forControlEvents:UIControlEventTouchUpInside];
        webIpad.backgroundColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
        [webIpad setTitle:@"www.triporg.org" forState:UIControlStateNormal];
        [webIpad setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [webIpad setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        webIpad.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:26];
        
        [webIpad.layer setCornerRadius:7.0f];
        [webIpad.layer setMasksToBounds:YES];
        
        [self.view addSubview:webIpad];
    }
    
    versionApp.text = [NSString stringWithFormat:@"Version %@",version];
    versionApp.backgroundColor = [UIColor clearColor];
    
    // iOS Version
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        [webButton setTitleColor:[UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1] forState:UIControlStateNormal];
    }
    
    [webButton.layer setCornerRadius:7.0f];
    [webButton.layer setMasksToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)webIr:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.triporg.org?pk_campaign=iOS"]]];
}


@end