//
//  TZRestrictionListViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 06/09/13.
//
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>


@interface TZRestrictionListController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    NSArray *citasArray;
}

@property (nonatomic, strong) NSString *hotelActive;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *createTripButton;

- (IBAction)finalShowdown:(id)sender;

@end
