//
//  TZWebDescriptionCell.m
//  Triporg
//
//  Created by Endika Salas on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZWebDescriptionCell.h"

@implementation TZWebDescriptionCell{
    CGFloat widthDesc;
}

@synthesize webView = _webView;
@synthesize onHeightCallback = _onHeightCallback;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            widthDesc = 1024;
        }
        else {
            widthDesc = 320;
        }
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, widthDesc, 200)];
        
        webView.scrollView.scrollEnabled = NO;
        webView.delegate = self;
        
        [self addSubview:webView];
        self.webView = webView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    NSString *result = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    CGFloat height = [result floatValue];
    webView.frame = CGRectMake(0, 0, widthDesc, height);
    if (_onHeightCallback)
        _onHeightCallback(height);
}

@end
