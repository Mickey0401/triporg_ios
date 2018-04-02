//
//  TZLoginViewController.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <FacebookSDK/FacebookSDK.h>

@class GPPSignInButton;

@interface TZLoginViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate, GPPSignInDelegate>

@property (nonatomic, assign) IBOutlet UIBarButtonItem *legalButton;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *returnButton;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *copyrightTriporg;
@property (retain, nonatomic) GPPSignInButton *googleLogin;
@property (retain, nonatomic) FBLoginView *facebookLogin;

- (IBAction)legal:(id)sender;
- (IBAction)outsideTap:(id)sender;
- (IBAction)backToNormal:(id)sender;

@end
