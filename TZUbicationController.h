//
//  TZUbicationController.h
//  Triporg
//
//  Created by Koldo Ruiz on 21/10/13.
//  
//

#import <UIKit/UIKit.h>

@interface TZUbicationController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIScrollViewDelegate>
{
     NSArray *ubicationsArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSString *cityName;
@property (weak, nonatomic) NSNumber *cityId;
@property (weak, nonatomic) NSString *isSecond;
@property (weak, nonatomic) NSString *detailText;
@property (weak, nonatomic) NSString *imageUrl;
@property (weak, nonatomic) UIImage *imageCity;

@end
