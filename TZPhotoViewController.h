//
//  TZPhotoTriporgViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 02/09/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>


@interface TZPhotoViewController : UIViewController <UIScrollViewDelegate, UIPopoverControllerDelegate> {
    UIImageView *demoImageView;
}

@property(nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *demoImageView;
@property(nonatomic, strong) UITapGestureRecognizer *singleTap;
@property(nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property(nonatomic, strong) UITapGestureRecognizer *twoFingerTap;
@property (nonatomic, strong) NSData *photoData;
@property (nonatomic, strong) UIPopoverController *popover;

@end
