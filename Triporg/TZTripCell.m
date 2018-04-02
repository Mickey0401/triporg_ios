//
//  TZTripCell.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTripCell.h"
#import "UIImage+Additions.h"
#import "UIColor+String.h"

#import <QuartzCore/QuartzCore.h>

@implementation TZTripCell

@synthesize onDownloadCallback = _onDownloadCallback;

@synthesize onCacheCallback = _onCacheCallback;

@synthesize cacheCleanerButton , downloadButton ,fechaSincro, photoDownload;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            viewWidth = 1024;
        }
        else {
            viewWidth = 320;
        }
        viewWidth = UIScreen.mainScreen.bounds.size.width;
        
        downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        downloadButton.userInteractionEnabled = YES;
        downloadButton.frame = CGRectMake(viewWidth - 60, 0, 60, 60);
        downloadButton.backgroundColor = [UIColor clearColor];
        [downloadButton addTarget:self action:@selector(onDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:downloadButton];
        
        cacheCleanerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cacheCleanerButton.userInteractionEnabled = YES;
        cacheCleanerButton.frame = CGRectMake(viewWidth - 60, 0, 60, 60);
        cacheCleanerButton.backgroundColor = [UIColor clearColor];
        [cacheCleanerButton addTarget:self action:@selector(onCacheTapped:) forControlEvents:UIControlEventTouchUpInside];
        cacheCleanerButton.hidden = YES;
        [self.contentView addSubview:cacheCleanerButton];
        
        photoDownload = [[UIImageView alloc] init];
        
        if (viewWidth > 320) {
            photoDownload.frame = CGRectMake(viewWidth - 40, 20, 30, 29);
        }
        else {
            photoDownload.frame = CGRectMake(viewWidth - 40, 10, 30, 29);
        }
        
        photoDownload.image = [[UIImage imageNamed:@"download"] tintImageWithColor:[UIColor lightGrayColor]];
        photoDownload.contentMode = UIViewContentModeScaleAspectFit;
        photoDownload.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:photoDownload];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor grayColor];
        
        fechaSincro = [[UILabel alloc] init];
        
        if (viewWidth > 320) {
            fechaSincro.frame = CGRectMake(viewWidth - 60, 44 , 60, 15);
        }
        else {
            fechaSincro.frame = CGRectMake(viewWidth - 60, 34 , 60, 15);
        }
        
        fechaSincro.text = @"11/12";
        fechaSincro.textColor = [UIColor grayColor];
        fechaSincro.backgroundColor = [UIColor clearColor];
        [fechaSincro setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
        fechaSincro.textAlignment = NSTextAlignmentCenter;
        fechaSincro.numberOfLines = 2;
        fechaSincro.hidden = YES;
        [self.contentView addSubview:fechaSincro];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    frame.size.width = viewWidth - 60;
    self.textLabel.frame = frame;
    
    frame = self.detailTextLabel.frame;
    frame.size.width = viewWidth - 70;
    self.detailTextLabel.frame = frame;
}

- (void)onDownloadTapped:(id)sender
{
    if (_onDownloadCallback)
        _onDownloadCallback(self);
}

- (void)onCacheTapped:(id)sender
{
    if (_onCacheCallback)
        _onCacheCallback(self);
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

@end
