//
//  TZTripEventHeader.m
//  Triporg
//
//  Created by Endika Salas on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTripEventHeader.h"
#import "UIColor+String.h"
#import "UIImage+Additions.h"

#import <QuartzCore/QuartzCore.h>

@implementation TZTripEventHeader

@synthesize textLabel = _textLabel;
@synthesize showMapCallback = _showMapCallback;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithString:@"#93D31B"];
        
        NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
        
        if ([versioniOS hasPrefix:@"6."]) {
            self.opaque = YES;
        }
        else {
            self.opaque = NO;
            self.alpha = 0.9;
        }
        
        self.layer.borderWidth = 0.3f;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        UIButton *showMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        showMapButton.userInteractionEnabled = YES;
        showMapButton.frame = CGRectMake(320 - 60, 0, 60, 37);
        [showMapButton addTarget:self action:@selector(showMapPressed:) forControlEvents:UIControlEventTouchUpInside];
        [showMapButton setImage:[[UIImage imageNamed:@"map-next"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [showMapButton setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        [showMapButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        showMapButton.backgroundColor = [UIColor clearColor];

        showMapButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:showMapButton];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            UIButton *invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            invisibleButton.backgroundColor = [UIColor clearColor];
            invisibleButton.frame = CGRectMake(0, 0, 320 - 60, 37);
            [invisibleButton addTarget:self action:@selector(showMapPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:invisibleButton];
        }
        
        UIView *whiteLineView = [[UIView alloc] initWithFrame:CGRectMake(320 - 61, 0, 0.5, 37)];
        whiteLineView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:whiteLineView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 270, 20)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
       
        self.textLabel = textLabel;
        [self addSubview:textLabel];
    }
    return self;
}

- (void)showMapPressed:(id)sender
{
    if (_showMapCallback)
        _showMapCallback(self);
}

@end
