//
//  TZPhotoTriporgViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 07/08/13.
//
//

#import "TZPhotoViewController.h"


@interface TZPhotoViewController (UtilityMethods)

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation TZPhotoViewController{
    NSInteger zoom;
    BOOL navigationBarInvisible;
}

@synthesize scrollView, demoImageView;
@synthesize singleTap, doubleTap, twoFingerTap;
@synthesize photoData;

#define ZOOM_STEP 1.5

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showAirDrop:)];
    self.navigationItem.rightBarButtonItem = flipButton;
    
    zoom = 0;
    navigationBarInvisible = NO;
    
    //Ajustes de Imagen y del ScrollView en la que en esta contenida.
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        scrollView.frame = CGRectMake(0, 0, 1024, 768);
    }
    
    scrollView.delegate = self;
    scrollView.bouncesZoom = YES;
    scrollView.clipsToBounds = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    self.view = scrollView;
    
    demoImageView = [[UIImageView alloc] initWithImage:nil];
    demoImageView.backgroundColor = [UIColor clearColor];
    demoImageView.contentMode = UIViewContentModeScaleAspectFit;
    demoImageView.userInteractionEnabled = YES;
    demoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ;
    
    UIImage *image = [UIImage imageWithData:photoData];
    photoData = nil;
    demoImageView.image = image;
    
    demoImageView.frame = CGRectMake(0,0, image.size.width, image.size.height);
    
    [scrollView setContentSize:CGSizeMake(demoImageView.frame.size.width, demoImageView.frame.size.height)];
    [scrollView addSubview:demoImageView];
    
    // add gesture recognizers to the image view
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [scrollView addGestureRecognizer:singleTap];
    [demoImageView addGestureRecognizer:doubleTap];
    [demoImageView addGestureRecognizer:twoFingerTap];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    CGFloat minimumScale = [scrollView frame].size.width / [demoImageView frame].size.width;
    scrollView.maximumZoomScale = 4.0;
    scrollView.minimumZoomScale = minimumScale;
    scrollView.zoomScale = minimumScale;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self centerScrollViewContents];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    self.navigationController.navigationBar.layer.opacity = 1;
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return demoImageView;
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (navigationBarInvisible == NO)
    {
        [UIView transitionWithView:self.navigationController.navigationBar duration:0.3
                           options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                               self.navigationController.navigationBar.layer.opacity = 0;
                           } completion:nil];
        
        navigationBarInvisible = YES;
    }
    else
    {
        [UIView transitionWithView:self.navigationController.navigationBar duration:0.3
                           options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                               self.navigationController.navigationBar.layer.opacity = 1;
                           } completion:nil];
        
        navigationBarInvisible = NO;
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (zoom == 3)
    {
        // Zooms out
        CGFloat newScale = [scrollView zoomScale] / (ZOOM_STEP * 3);
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        zoom = 0;
    }
    else
    {
        // Zoom in
        CGFloat newScale = [scrollView zoomScale] * ZOOM_STEP;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        zoom++;
    }
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (zoom != 0)
    {
        CGFloat newScale = [scrollView zoomScale] / ZOOM_STEP;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        
        zoom--;
    }
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

/** Abre una ventana para copiar, guardar o compartir la imagen */
- (void)showAirDrop:(id)sender
{
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[demoImageView.image] applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:shareController];
        self.popover.delegate = self;
        [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:shareController animated:YES completion:nil];
    }
}

/** Centra el contenido del ScrollView */
- (void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.demoImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.demoImageView.frame = contentsFrame;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}


@end