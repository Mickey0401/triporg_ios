//
//  TZWebDescriptionCell.h
//  Triporg
//
//  Created by Endika Salas on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZWebDescriptionCell : UITableViewCell <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, copy) void(^onHeightCallback)(CGFloat);

@end
