//
//  TZCommentViewController.h
//  Triporg
//
//  Created by Koldo Ruiz on 03/10/13.
//
//

#import <UIKit/UIKit.h>

enum TZCommentType {
    TZCommentTypeEvent = 0,
    TZCommentTypeLocation = 1,
};

@interface TZCommentViewController : UIViewController <UITextViewDelegate,UIAlertViewDelegate , UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) NSNumber *eventId;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) enum TZCommentType type;


@end
