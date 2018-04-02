//
//  TZTripHeaderCell.m
//  Triporg
//
//  Created by Endika Salas on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTripHeaderCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TZTripHeaderCell

@synthesize headerImageView = _headerImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat imageViewWidth;
        CGFloat imageViewHeight;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            imageViewWidth = 1024;
            imageViewHeight = 300;
        }
        else {
            imageViewWidth = 320;
            imageViewHeight = 200;
        }
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
        headerView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:headerView];
        self.headerImageView = headerView;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];
}

@end
