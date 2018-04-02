//
//  TZMenuTableViewCell.m
//  Triporg
//
//  Created by Koldo Ruiz on 24/06/14.
//
//

#import "TZMenuTableViewCell.h"

@implementation TZMenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.imageView.frame;
    frame.size.width -= 10;
    frame.size.height -= 10;
    frame.origin.y += 5;
    self.imageView.frame = frame;
}

@end
