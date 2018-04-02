//
//  TZTripCell.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZTripCell : UITableViewCell{
    CGFloat viewWidth;
}

@property (nonatomic, copy) void(^onDownloadCallback)(TZTripCell *);
@property (nonatomic, copy) void(^onCacheCallback)(TZTripCell *);
@property ( nonatomic ,copy) UIButton *downloadButton;
@property ( nonatomic ,copy) UIButton *cacheCleanerButton;
@property (nonatomic ,copy) UILabel *fechaSincro;
@property (nonatomic ,copy) UIImageView *photoDownload;

@end
