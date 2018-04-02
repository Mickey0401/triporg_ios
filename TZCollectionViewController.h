//
//  TZCollectionViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 21/10/13.
//  
//

#import <UIKit/UIKit.h>


@interface TZCollectionViewController : UIViewController <UISearchBarDelegate , UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, UIScrollViewDelegate>{
    NSArray *cityCollectArray;
    NSArray *filteredCitiesArray;
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UISearchBar *searchMyCityPhoto;

- (void)refreshCities:(id)sender;
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;

@end
