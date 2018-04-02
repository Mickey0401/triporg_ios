//
//  TZTripsTableController.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TZTrip;

@interface TZTripsTableController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSArray *_trips;
    NSArray *_cities;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
