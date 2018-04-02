//
//  TZTripHeaderiPadCell.m
//  Triporg
//
//  Created by Koldo Ruiz on 18/03/14.
//
//

#import "TZTripHeaderiPadCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TZTripHeaderiPadCell

@synthesize headerImageView = _headerImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 704, 300)];
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
