//
//  TZDestinationViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 23/09/13.
//
//

#import <UIKit/UIKit.h>

@interface TZDestinationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate>{
    NSArray *ciudadesArray;
    NSArray *_filteredEvents;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchMyCity;

@end
