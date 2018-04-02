//
//  TZCollectionViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 21/10/13.
//
//

#import "TZCollectionViewController.h"
#import "TZCollectionViewCell.h"
#import "TZCollectionHeaderView.h"
#import "TZUbicationController.h"
#import <QuartzCore/QuartzCore.h>
#import "TZTriporgManager.h"
#import "NSArray+Additions.h"
#import "UIImage+Additions.h"
#import "WebImageOperations.h"
#import "UIColor+String.h"
#import "TZCity.h"
#import <Social/Social.h>

@interface TZCollectionViewController () {
    NSArray *searchPhotoCitiesArray;
    NSMutableArray *nameForHeaders;
    NSString *headerStringForSearch;
    UIView *darkView;
    UIRefreshControl *refreshControl;
    NSString *versioniOS;
    NSInteger counterCt;
    BOOL searchActivated;
}

@end

@implementation TZCollectionViewController

@synthesize searchMyCityPhoto;

@synthesize collectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Explora", @"");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showMyScope:)];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshCities:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    counterCt = 0;
    searchActivated = NO;
    
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    darkView = [[UIView alloc] initWithFrame:CGRectMake(self.collectionView.layer.bounds.origin.x, self.collectionView.layer.bounds.origin.y, self.view.layer.bounds.size.width, self.view.layer.bounds.size.height)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        darkView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        darkView.backgroundColor = [UIColor blackColor];
    }
    
    darkView.userInteractionEnabled = NO;
    darkView.alpha = 0;
    [self.view addSubview:darkView];
    
    searchMyCityPhoto = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 63, self.view.bounds.size.width, 44)];
    searchMyCityPhoto.delegate = self;
    searchMyCityPhoto.alpha = 0;
    searchMyCityPhoto.tintColor = [UIColor colorWithRed:0.49 green:0.72 blue:0 alpha:1];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect frame = searchMyCityPhoto.frame;
        frame.origin.x = 128;
        frame.origin.y = frame.origin.y + 7;
        searchMyCityPhoto.frame = frame;
        searchMyCityPhoto.layer.borderWidth = 1.0f;
        searchMyCityPhoto.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        [searchMyCityPhoto.layer setCornerRadius:7.0f];
        [searchMyCityPhoto.layer setMasksToBounds:YES];
    }
    
    [self.view addSubview:searchMyCityPhoto];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        self.collectionView.backgroundColor = [UIColor colorWithString:@"#eeeeee"];
    }
    else
    {
        searchMyCityPhoto.searchBarStyle = UISearchBarStyleMinimal;
    }
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    cityCollectArray = [[NSArray alloc] init];
    
    searchPhotoCitiesArray = [[NSArray alloc] init];
    
    [[TZTriporgManager sharedManager] getAllCitiesWithPhotos:^(NSArray *cities) {
        if ([cities isKindOfClass:[NSError class]])
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                        message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
        }
        else
        {
            searchPhotoCitiesArray = cities;
            
            cities = [cities sortedArrayUsingComparator:^NSComparisonResult(TZCity *c1, TZCity *c2) {
                return [c1.country compare:c2.country];
                
            }];
            
            // Group cities by country
            NSMutableArray *citiesGrouped = [NSMutableArray array];
            
            NSString *currentCountry;
            NSMutableArray *citiesBlock;
            
            nameForHeaders = [[NSMutableArray alloc] init];
            
            for (TZCity *myCity in cities)
            {
                if ([myCity.country isEqualToString:currentCountry] == NO)
                {
                    currentCountry = myCity.country;
                    citiesBlock = [NSMutableArray array];
                    [citiesGrouped addObject:citiesBlock];
                    [nameForHeaders addObject:currentCountry];
                    counterCt++;
                }
                
                [citiesBlock addObject:myCity];
            }
            cityCollectArray = citiesGrouped;
            
            [self performSelector:@selector(reloadCollectionView:) withObject:nil];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** Recarga el collectionView */
- (void)reloadCollectionView:(id)sender
{
    [self.collectionView reloadData];
}

/** Muestra el buscador */
- (void)showMyScope:(id)sender
{
    if (searchActivated == NO)
    {
        searchActivated = YES;
        searchMyCityPhoto.alpha = 1;
        
        if (searchMyCityPhoto.text.length == 0)
            darkView.alpha = 0.5;
        
        [searchMyCityPhoto becomeFirstResponder];
    }
    else
    {
        searchActivated = NO;
        searchMyCityPhoto.alpha = 0;
        darkView.alpha = 0;
        [searchMyCityPhoto resignFirstResponder];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the number of sections.
    return (filteredCitiesArray ? 1 : cityCollectArray.count);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (filteredCitiesArray ? filteredCitiesArray.count : [[cityCollectArray objectAtIndex:section] count]);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        TZCollectionHeaderView *headerView;
        
        headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.countryLabel.textColor = [UIColor whiteColor];
        headerView.backgroundColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
        
        if (filteredCitiesArray)
        {
            headerView.imageCountry.image = [[UIImage imageNamed:@"search"] tintImageWithColor:[UIColor whiteColor]];
        }
        else
        {
            headerView.imageCountry.image = [[UIImage imageNamed:@"city"] tintImageWithColor:[UIColor whiteColor]];
        }
        
        for (NSInteger i = 0; i < counterCt; i++)
        {
            if (indexPath.section == i)
            {
                headerView.countryLabel.text = [nameForHeaders objectAtIndex:i];
            }
        }
        
        headerView.layer.borderWidth = 0.3f;
        headerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        if (filteredCitiesArray)
        {
            if (headerStringForSearch.length > 0)
            {
                headerView.countryLabel.text = headerStringForSearch;
            }
            else
            {
                headerView.countryLabel.text = @"";
            }
        }
        
        headerView.alpha = 0.9;
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        UICollectionReusableView *footerview;
        
        footerview = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        if (indexPath.section == counterCt - 1 )
        {
            footerview.alpha = 1;
        }
        else
        {
            footerview.alpha = 0;
        }
        
        reusableview = footerview;
    }
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    TZCollectionViewCell *cell = (TZCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imageBackground = [[UIImageView alloc] initWithImage:nil];
    imageBackground.backgroundColor = [UIColor whiteColor];
    
    cell.backgroundView = imageBackground;
    
    UIImageView *selectedImageBackground = [[UIImageView alloc] initWithImage:nil];
    selectedImageBackground.backgroundColor = [UIColor lightGrayColor];
    
    cell.selectedBackgroundView = selectedImageBackground;
    
    cell.layer.borderWidth = 0.3f;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    TZCity *cityItem;
    
    NSArray *citiesOnSection = [cityCollectArray objectAtIndex:indexPath.section];
    
    cityItem = filteredCitiesArray ? [filteredCitiesArray objectAtIndex:indexPath.row] : [citiesOnSection objectAtIndex:indexPath.row];
    
    cell.recipeLabel.text = cityItem.nombre;
    
    [cell.layer setCornerRadius:7.0f];
    [cell.layer setMasksToBounds:YES];
    
    cell.recipeImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (cityItem.imageSaved)
    {
        cell.recipeImageView.image = cityItem.imageSaved;
        cell.recipeImageView.alpha = 1;
    }
    else
    {
        // set default user image while image is being downloaded
        cell.recipeImageView.image = [UIImage imageNamed:@"city-image"];
        cell.recipeImageView.alpha = 0.2;
        
        if ([cityItem.image rangeOfString:@"defaultInfoGrande"].location == NSNotFound)
        {
            // download the image asynchronously
            [self downloadImageWithURL:[NSURL URLWithString:[cityItem.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]] completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    // change the image in the cell
//                    if (cell.recipeImageView.image == [UIImage imageNamed:@"city-image"])
                    {
                        cell.recipeImageView.image = image;
                        cell.recipeImageView.alpha = 1;
                        
                        // cache the image for use later (when scrolling up)
                        cityItem.imageSaved = image;
                    }
                }
            }];
        }
        else
        {
            
        }
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showRecipePhoto"])
    {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        TZUbicationController *destViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        TZCity *citySegue;
        
        NSArray *citiesOnTheSection = [cityCollectArray objectAtIndex:indexPath.section];
        citySegue = filteredCitiesArray ? [filteredCitiesArray objectAtIndex:indexPath.row] : [citiesOnTheSection objectAtIndex:indexPath.row];
        destViewController.cityId = citySegue.id;
        destViewController.cityName = citySegue.nombre;
        destViewController.imageCity = citySegue.imageSaved;
        destViewController.imageUrl = citySegue.image;
        destViewController.detailText = citySegue.country;
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
    searchMyCityPhoto.alpha = 0;
    darkView.alpha = 0;
    searchActivated = NO;
    
    headerStringForSearch = theSearchBar.text;
    
    if (!theSearchBar.text || theSearchBar.text.length == 0)
    {
        [theSearchBar endEditing:YES];
        [theSearchBar resignFirstResponder];
        filteredCitiesArray = nil;
        [self.collectionView reloadData];
        
        return;
    }
    
    filteredCitiesArray = [searchPhotoCitiesArray collect:^id(TZCity *e) {
        BOOL match =
        [e.nombre.lowercaseString rangeOfString:theSearchBar.text.lowercaseString].location != NSNotFound ||
        [e.country.lowercaseString rangeOfString:theSearchBar.text.lowercaseString].location != NSNotFound;
        return match ? e : nil;
        
    }];
    [self.collectionView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!searchText || searchText.length == 0)
    {
        // [searchBar endEditing:YES];
        // [searchBar resignFirstResponder];
        filteredCitiesArray = nil;
        [self.collectionView reloadData];
        darkView.alpha = 0.5;
        
        return;
    }
    
    if (searchText.length > 0)
    {
        darkView.alpha = 0;
    }
    
    filteredCitiesArray = [searchPhotoCitiesArray collect:^id(TZCity *e) {
        BOOL match =
        [e.nombre.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound
        || [e.country.lowercaseString rangeOfString:searchText.lowercaseString].location != NSNotFound;
        return match ? e : nil;
    }];
    [self.collectionView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    searchBar.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.backgroundColor = [UIColor clearColor];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    /*
     _filteredEvents = nil;
     searchBar.text = @"";
     [self.tableView reloadData];
     */
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    filteredCitiesArray = nil;
    searchBar.text = @"";
    searchActivated = NO;
    searchMyCityPhoto.alpha = 0;
    darkView.alpha = 0;
    
    [self.collectionView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Ok", @"Ok")])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)refreshCities:(id)sender
{
    if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable)
    {
        [refreshControl endRefreshing];
    }
    else
    {
        [[TZTriporgManager sharedManager] refreshAllCities:^(NSArray *cities) {
            if ([cities isKindOfClass:[NSError class]])
            {
                [refreshControl endRefreshing];
            }
            else
            {
                searchPhotoCitiesArray = cities;
                
                cities = [cities sortedArrayUsingComparator:^NSComparisonResult(TZCity *c1, TZCity *c2) {
                    return [c1.country compare:c2.country];
                    
                }];
                
                // Group cities by country
                NSMutableArray *citiesGrouped = [NSMutableArray array];
                
                NSString *currentCountry;
                NSMutableArray *citiesBlock;
                
                nameForHeaders = [[NSMutableArray alloc] init];
                
                for (TZCity *myCity in cities)
                {
                    if ([myCity.country isEqualToString:currentCountry] == NO)
                    {
                        currentCountry = myCity.country;
                        citiesBlock = [NSMutableArray array];
                        [citiesGrouped addObject:citiesBlock];
                        [nameForHeaders addObject:currentCountry];
                        counterCt++;
                    }
                    
                    [citiesBlock addObject:myCity];
                }
                cityCollectArray = citiesGrouped;
                
                [refreshControl endRefreshing];
                
                [self performSelector:@selector(reloadCollectionView:) withObject:nil];
            }
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        [self performSelector:@selector(reloadCollectionView:) withObject:nil];
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error)
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               }
                               else
                               {
                                   completionBlock(NO,nil);
                               }
                           }];
}

@end
