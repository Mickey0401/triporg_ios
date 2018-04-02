//
//  TZTripDetailViewController.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKRevealingTableViewCell.h"

@class TZTrip;

@interface TZTripEventsTableController : UIViewController <UISearchBarDelegate, UIAlertViewDelegate , UITableViewDelegate , UITableViewDataSource, UIScrollViewDelegate, UIPopoverControllerDelegate> {
    NSArray *_eventsByDays;
    NSArray *_allEvents;
    NSArray *_filteredEvents;
    BOOL _tripHasChange;
}

@property (nonatomic, retain) TZTrip *trip;
@property (nonatomic) BOOL editing;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) UIPopoverController *popover;

- (id)initWithTopView:(UIView*)view;

@end
