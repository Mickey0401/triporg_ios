//
//  TZAboutViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 10/07/13.
//
//

#import <UIKit/UIKit.h>

@interface TZAboutViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *copyrightT;
@property (nonatomic, weak) IBOutlet UILabel *versionApp;
@property (nonatomic, weak) IBOutlet UIButton *webButton;
@property (nonatomic, weak) IBOutlet UIImageView *logoAbout;
@property (nonatomic, weak) IBOutlet UITextView *textoAtribuciones;

- (IBAction)webIr:(id)sender;

@end
