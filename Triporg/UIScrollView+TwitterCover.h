//
//  UIScrollView+TwitterCover.h
//  Triporg
//
//  Created by cyndibaby905 on 29/01/14.
//
//

#import <UIKit/UIKit.h>
#define CHTwitterCoverViewHeight 80

@interface CHTwitterCoverView : UIImageView
@property (nonatomic, weak) UIScrollView *scrollView;
- (id)initWithFrame:(CGRect)frame andContentTopView:(UIView*)view;
@end


@interface UIScrollView (TwitterCover)
@property(nonatomic,weak)CHTwitterCoverView *twitterCoverView;
- (void)addTwitterCoverWithImage:(UIImage*)image;
- (void)addTwitterCoverWithImage:(UIImage*)image withTopView:(UIView*)topView;
- (void)removeTwitterCoverView;
@end

@interface UIImage (Blur)
- (UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end