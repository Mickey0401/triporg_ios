//
//  TZTripEventCell.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ZKRevealingTableViewCell.h"

@interface TZTripEventCell : ZKRevealingTableViewCell {
    BOOL _buttonsAdded;
    BOOL _shouldUpdate;
    CGFloat tableWidth;
}

@property (nonatomic, weak) UIButton *confirmButton;
@property (nonatomic, weak) UIButton *triporgButton;
@property (nonatomic, weak) UIButton *denegateButton;
@property (nonatomic, weak) UIView *colorStrip;
@property (nonatomic, weak) UIView *colorStripEdit;
@property (nonatomic, strong) UIView *separatorContainer;
@property (nonatomic, weak) UILabel *separationLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIImageView *photoView;
@property (nonatomic, weak) UIImageView *overlayView;
@property (nonatomic, strong) UIImageView *bevelView;
@property (nonatomic, strong) UIImageView *trianguloView;
@property (nonatomic, strong) UIImageView *lineCellView;
@property (nonatomic, strong) UIImageView *appointmentView;
@property (nonatomic) BOOL editable;
@property (nonatomic) BOOL eventSelected;
@property (nonatomic) BOOL citaOn;
@property (nonatomic) BOOL hotelOn;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, copy) void(^onIndexChanged)(NSInteger index);


@end
