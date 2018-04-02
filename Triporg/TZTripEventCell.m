//
//  TZTripEventCell.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTripEventCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+String.h"
#import "UIImage+Additions.h"

@implementation TZTripEventCell

@synthesize confirmButton;
@synthesize triporgButton;
@synthesize denegateButton;
@synthesize colorStrip = _colorStrip;
@synthesize colorStripEdit = _colorStripEdit;
@synthesize separationLabel = _separationLabel;
@synthesize separatorContainer = _separatorContainer;
@synthesize photoView = _photoView;
@synthesize editable = _editable;
@synthesize timeLabel = _timeLabel;
@synthesize bevelView = _bevelView;
@synthesize overlayView = _overlayView;
@synthesize citaOn = _citaOn;
@synthesize hotelOn = _hotelOn;
@synthesize eventSelected = _eventSelected;
@synthesize selectedIndex = _selectedIndex;
@synthesize onIndexChanged = _onIndexChanged;
@synthesize trianguloView , lineCellView ,appointmentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UIView *colorStrip = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 60)];
        
        colorStrip.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:colorStrip];
        self.colorStrip = colorStrip;
        
        UIView *colorStripEdit = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 60)];
        
        colorStripEdit.backgroundColor = [UIColor redColor];
        colorStripEdit.layer.opacity = 1;
        [self.contentView addSubview:colorStripEdit];
        self.colorStripEdit = colorStripEdit;
        
        colorStripEdit.hidden = YES;
        
        tableWidth = 320;
        
        UIView *separatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 60, tableWidth, 20)];
        
        separatorContainer.backgroundColor = [UIColor colorWithString:@"#E4E2DF"];
        separatorContainer.alpha = 0.9;
        separatorContainer.layer.borderWidth = 0.3f;
        separatorContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 300, 16)];
        
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor darkGrayColor];
        textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.separationLabel = textLabel;
        
        [separatorContainer addSubview:textLabel];
        self.separatorContainer = separatorContainer;
        [self addSubview:separatorContainer];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 230, 16)];
        
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        self.separatorContainer = separatorContainer;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableWidth - 90, 0, 90, 60)];
        
        imageView.contentMode = UIViewContentModeScaleToFill;
        self.photoView = imageView;
        [self.contentView addSubview:imageView];
        
        appointmentView = [[UIImageView alloc] initWithFrame:CGRectMake(tableWidth  - 75, 5, 90, 50)];
        appointmentView.image = [[UIImage imageNamed:@"appointment-image"] tintImageWithColor:[UIColor lightGrayColor]];;
        appointmentView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:appointmentView];
        appointmentView.hidden = YES;
        
        UIImageView *overlayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 60)];
        overlayView.image = [UIImage imageNamed:@"ImageOverlay"];
        overlayView.contentMode = UIViewContentModeScaleToFill;
        [self.photoView addSubview:overlayView];
        self.overlayView = overlayView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.selectedIndex = 1;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.userInteractionEnabled = YES;
        button.tag = 2;
        [button addTarget:self action:@selector(onSelectedChanged:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.opacity = 0.82;
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.backView addSubview:button];
        self.confirmButton = button;
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.userInteractionEnabled = YES;
        button.tag = 1;
        [button addTarget:self action:@selector(onSelectedChanged:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.backView addSubview:button];
        self.triporgButton = button;
        
        [triporgButton setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.userInteractionEnabled = YES;
        button.tag = 0;
        [button addTarget:self action:@selector(onSelectedChanged:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.backView addSubview:button];
        self.denegateButton = button;
        
        self.selectedIndex = 0;
        
        UIImageView *bevelView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 8, 40)];
        bevelView.opaque = NO;
        bevelView.image = [UIImage imageNamed:@"Pattern"];
        self.bevelView = bevelView;
        
        trianguloView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 42.5, 12, 12)];
        trianguloView.opaque = NO;
        trianguloView.image = nil;
        trianguloView.alpha = 0.6;
        trianguloView.contentMode = UIViewContentModeScaleAspectFit;
        trianguloView.backgroundColor = [UIColor clearColor];
        
        self.trianguloView = trianguloView;
        
        lineCellView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 59.5, tableWidth, 0.5)];
        lineCellView.alpha = 0.5;
        lineCellView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"CellHeaderBackground"] tintImageWithColor:[UIColor grayColor]]];
        self.lineCellView = lineCellView;
        
    }
    return self;
}

- (void)setEventSelected:(BOOL)eventSelected
{
    if (_eventSelected != eventSelected) {
        _shouldUpdate = YES;
        _eventSelected = eventSelected;
    }
}

- (void)setEditable:(BOOL)editable
{
    if (_editable != editable) {
        _editable = editable;
        [self.contentView setNeedsLayout];
    }
}

static UIColor *cellBackgroundColor()
{
    static UIColor *color = nil;
    if (!color) {
        color = [UIColor whiteColor];
    }
    return color;
}

static UIColor *selectedCellBackgroundColor()
{
    static UIColor *color = nil;
    if (!color) {
        color = [UIColor lightGrayColor];
    }
    return color;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.photoView.hidden = self.photoView.image ? NO : YES;
    if (_shouldUpdate) {
        if (_eventSelected) {
            self.contentView.backgroundColor = selectedCellBackgroundColor();
            self.overlayView.image = [UIImage imageNamed:@"ImageOverlaySelected"];
            self.photoView.layer.opacity = 1;
            self.textLabel.layer.opacity = 0.6;
            self.detailTextLabel.layer.opacity = 0.7;
            
        } else {
            self.contentView.backgroundColor = cellBackgroundColor();
            self.overlayView.image = [UIImage imageNamed:@"ImageOverlay"];
            self.photoView.layer.opacity = 1;
            self.textLabel.layer.opacity = 1;
            self.detailTextLabel.layer.opacity = 1;
        }
        _shouldUpdate = NO;
    }
    if (_editable) {
        if (_eventSelected) {
            self.contentView.backgroundColor = cellBackgroundColor();
            self.overlayView.image = [UIImage imageNamed:@"ImageOverlay"];
            self.photoView.layer.opacity = 1;
            self.textLabel.layer.opacity = 1;
            self.detailTextLabel.layer.opacity = 1;
        } else {
            self.contentView.backgroundColor = selectedCellBackgroundColor();
            self.overlayView.image = [UIImage imageNamed:@"ImageOverlaySelected"];
            self.photoView.layer.opacity = 1;
            self.textLabel.layer.opacity = 0.6;
            self.detailTextLabel.layer.opacity = 0.7;
        }
        
        self.direction = ZKRevealingTableViewCellDirectionRight;
        
     
            self.rightMargin = 80.0f;
        
        [self.separatorContainer removeFromSuperview];
        [self.contentView addSubview:self.bevelView];
        [self.contentView addSubview:self.trianguloView];
        [self.contentView addSubview:self.colorStrip];
        [self.contentView addSubview:self.lineCellView];
        appointmentView.hidden = YES;
        
        CGRect frame = self.textLabel.frame;
        frame.origin.x = 26;
        self.textLabel.frame = frame;
        
        frame = self.detailTextLabel.frame;
        frame.origin.x = 26;
        frame.origin.y = 33;
        frame.size.height = 14;
        self.detailTextLabel.frame = frame;
        
        frame = self.timeLabel.frame;
        frame.origin.x = 26;
        self.timeLabel.frame = frame;
        
    } else {
        if (_citaOn || _hotelOn) {
            self.contentView.backgroundColor = [UIColor colorWithRed:0.88 green:0.94 blue:0.88 alpha:1];
            appointmentView.hidden = NO;
            self.photoView.hidden = YES;
        }
        else {
            self.contentView.backgroundColor = cellBackgroundColor();
            appointmentView.hidden = YES;
            CGRect frame = self.separatorContainer.frame;
            frame.origin.y = 60;
            self.separatorContainer.frame = frame;
        }
        
        self.overlayView.image = [UIImage imageNamed:@"ImageOverlay"];
        self.photoView.layer.opacity = 1;
        self.textLabel.layer.opacity = 1;
        self.detailTextLabel.layer.opacity = 1;
        [self addSubview:self.separatorContainer];
        self.direction = ZKRevealingTableViewCellDirectionNone;
        [self.bevelView removeFromSuperview];
        [self.trianguloView removeFromSuperview];
        [self.lineCellView removeFromSuperview];
        
        CGRect frame = self.textLabel.frame;
        frame.origin.x = 10;
        self.textLabel.frame = frame;
        
        frame = self.detailTextLabel.frame;
        frame.origin.x = 10;
        self.detailTextLabel.frame = frame;
        
        frame = self.timeLabel.frame;
        frame.origin.x = 10;
        self.timeLabel.frame = frame;
    }
    
    CGRect frame = self.textLabel.frame;
    frame.size.width = tableWidth - 50;
    frame.origin.y = 4;
    self.textLabel.frame = frame;
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    self.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    frame = self.detailTextLabel.frame;
    frame.size.width = tableWidth - 80;
    frame.origin.y = 22;
    self.detailTextLabel.numberOfLines = 1;
    self.detailTextLabel.frame = frame;
    self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.detailTextLabel.textColor = [UIColor blackColor];
    
    self.confirmButton.frame = CGRectMake(0, 10, 80, 40);
    self.triporgButton.frame = CGRectMake(80, 10, 80, 40);
    self.denegateButton.frame = CGRectMake(160, 10, 80, 40);
    
    self.confirmButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)onSelectedChanged:(UIButton *)sender
{
    self.selectedIndex = sender.tag;
    
    switch (self.selectedIndex)
    {
        case 0:
            [UIView transitionWithView:self.denegateButton duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                                   
                               } completion:nil];
            
            break;
        case 1:
            [UIView transitionWithView:self.triporgButton duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
                                   
                               } completion:nil];
            
            break;
        case 2:
            [UIView transitionWithView:self.confirmButton duration:0.4
                               options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                                   
                               } completion:nil];
            
            break;
    }
    
    
    if (_onIndexChanged)
        _onIndexChanged(sender.tag);
}

- (void)setSelectedIndex:(NSInteger )selectedIndex
{
    _selectedIndex = selectedIndex;
    switch (selectedIndex)
    {
        case 0:
            [self.confirmButton setImage:[[UIImage imageNamed:@"TrueWhite"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
            [self.triporgButton setImage:[[UIImage imageNamed:@"TriporgWhite"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
            [self.denegateButton setImage:[[UIImage imageNamed:@"FalseWhite"] tintImageWithColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]] forState:UIControlStateNormal];
            
            trianguloView.image = [[UIImage imageNamed:@"FalseWhite"] tintImageWithColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.7]];
            trianguloView.backgroundColor = [UIColor clearColor];
            
            self.confirmButton.alpha = 0.5;
            self.triporgButton.alpha = 0.5;
            self.denegateButton.alpha = 1;
            
            break;
        case 1:
            [self.confirmButton setImage:[[UIImage imageNamed:@"TrueWhite"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
            [self.triporgButton setImage:[[UIImage imageNamed:@"TriporgWhite"] tintImageWithColor:[UIColor colorWithRed:0 green:0.43 blue:0.7 alpha:1]] forState:UIControlStateNormal];
            [self.denegateButton setImage:[[UIImage imageNamed:@"FalseWhite"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
            
            trianguloView.image = nil;
            trianguloView.backgroundColor = [UIColor clearColor];
            
            self.confirmButton.alpha = 0.5;
            self.triporgButton.alpha = 1;
            self.denegateButton.alpha = 0.5;
            
            break;
        case 2:
            [self.confirmButton setImage:[[UIImage imageNamed:@"TrueWhite"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]] forState:UIControlStateNormal];
            [self.triporgButton setImage:[[UIImage imageNamed:@"TriporgWhite"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
            [self.denegateButton setImage:[[UIImage imageNamed:@"FalseWhite"] tintImageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
            
            trianguloView.image = [[UIImage imageNamed:@"TrueWhite"] tintImageWithColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1]];
            trianguloView.backgroundColor = [UIColor clearColor];
            
            self.confirmButton.alpha = 1;
            self.triporgButton.alpha = 0.5;
            self.denegateButton.alpha = 0.5;
            
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
}

@end
