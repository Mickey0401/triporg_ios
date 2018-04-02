//
//  TZCommentViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 03/10/13.
//
//

#import "TZCommentViewController.h"
#import "MBProgressHUD.h"
#import "TZTriporgManager.h"
#import "TZComment.h"
#import "UIImage+Additions.h"
#import "UIColor+String.h"
#import "TZUser.h"
#import "TZWebDescriptionCell.h"

#define HTML_BODY   \
@"<!DOCTYPE html>\
<html>\
<head>\
<style>body { font-family: HelveticaNeue; width: %fpx; margin: 0; padding: 5px 10px; text-align: left; } footer {font-family: HelveticaNeue-UltraLight; display: block; color: gray; font-style: italic; font-size: 14px; text-align: right } </style>\
</head>\
<body>\
<div id=\"main\">\
<article>%@</article>\
<div>\
</div>\
<footer>\
%@\
</footer>\
</div>\
</body>\
</html>"

@interface TZCommentViewController () {
    UITextView *comentBox;
    UIButton *sendComentButton;
    UILabel *letterCountLabel;
    NSNumber *myUserId;
    UIView *footerCommentView;
    UIView *noCommentsView;
    NSString *versioniOS;
    NSInteger letterCount;
}

@end

@implementation TZCommentViewController

@synthesize commentsArray, eventId, type, eventName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    versioniOS = [[UIDevice currentDevice] systemVersion];
    
    letterCount = 0;
    
    myUserId = [TZTriporgManager sharedManager].currentUser.id;
    
    self.title = NSLocalizedString(@"Comentarios", @"");
    
    footerCommentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height -100, self.view.bounds.size.width, 100)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([versioniOS hasPrefix:@"6."])
        {
            footerCommentView.frame = CGRectMake(0, 768 - 164, 1024, 100);
        }
        else
        {
            footerCommentView.frame = CGRectMake(0, 768 - 100, 1024, 100);
        }
    }
    
    footerCommentView.backgroundColor = [UIColor clearColor];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        toolBar.frame = CGRectMake(0, 0, 1024, 100);
    }
    toolBar.barStyle = UIBarStyleDefault;
    [footerCommentView addSubview:toolBar];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        comentBox = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 1024 - 80, 70)];
    }
    else
    {
        comentBox = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width - 80, 80)];
    }
    
    comentBox.backgroundColor = [UIColor whiteColor];
    comentBox.layer.borderWidth = 0.3f;
    comentBox.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    if ([versioniOS hasPrefix:@"6."])
    {
        
    }
    else
    {
        comentBox.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    }
    
    [comentBox.layer setCornerRadius:7.0f];
    [comentBox.layer setMasksToBounds:YES];
    comentBox.delegate = self;
    comentBox.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    comentBox.text = [NSString stringWithFormat:NSLocalizedString(@"¿Te ha gustado '%@'?", @""), eventName];
    comentBox.textColor = [UIColor lightGrayColor];
    
    [footerCommentView addSubview:comentBox];
    
    sendComentButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 15, 60, 60)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        sendComentButton.frame = CGRectMake(1024 - 60, 15, 60, 60);
    }
    
    sendComentButton.backgroundColor = [UIColor clearColor];
    [sendComentButton setTitle:NSLocalizedString(@"Enviar", @"") forState:UIControlStateNormal];
    [sendComentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [sendComentButton addTarget:self action:@selector(sendComentary:) forControlEvents:UIControlEventTouchUpInside];
    
    sendComentButton.enabled = NO;
    
    [footerCommentView addSubview:sendComentButton];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        letterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(1024 - 35, 50, 40, 40)];
    }
    else
    {
        letterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 35, 60, 40, 40)];
    }
    
    letterCountLabel.text = @"255";
    letterCountLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    letterCountLabel.textColor = [UIColor lightGrayColor];
    letterCountLabel.backgroundColor = [UIColor clearColor];
    [footerCommentView addSubview:letterCountLabel];
    
    [self.view addSubview:footerCommentView];
    
    // Colocar un footer de tamaño 0 impide que se dibujen separator lines en las celdas vacias en iOS 7
    UIView *footer =
    [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TZComment *commentObject;
    commentObject = [commentsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self removedHTMLtagsFromString:commentObject.text];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", commentObject.user,commentObject.date];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
    
    if ([commentObject.user_id isEqualToNumber:myUserId])
    {
        cell.backgroundColor = [UIColor colorWithRed:0.88 green:0.94 blue:0.88 alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TZComment *commentObjectHeight;
    commentObjectHeight = [commentsArray objectAtIndex:indexPath.row];
    
    NSString *cellValue = commentObjectHeight.text;
    
    NSString *cellText = cellValue;
    UIFont *cellFont = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 35;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (commentsArray.count > 0)
    {
        @try {
            TZComment *commentObjectEdit;
            commentObjectEdit = [commentsArray objectAtIndex:indexPath.row];
            
            if ([commentObjectEdit.user_id isEqualToNumber:myUserId])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        @catch (NSException *exception) {
            return YES;
        }
    }
    else
    {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        
        if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                        message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
        }
        else
        {
            TZComment *commentDelete;
            
            commentDelete = [commentsArray objectAtIndex:indexPath.row];
            if (type == TZCommentTypeEvent)
            {
                [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [[TZTriporgManager sharedManager] deleteEventComment:commentDelete.id callback:^(id result) {
                    [self performSelector:@selector(reloadCommentList:) withObject:nil];
                    
                }];
            }
            else
            {
                [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [[TZTriporgManager sharedManager] deleteLocationComment:commentDelete.id callback:^(id result) {
                    [self performSelector:@selector(reloadCommentList:) withObject:nil];
                    
                }];
            }
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/** Envia un comentario */
- (void)sendComentary:(id)sender
{
    NSString *comentString = comentBox.text;
    if (comentString.length > 0)
    {
        if ([TZTriporgManager sharedManager].reachability.currentReachabilityStatus == NotReachable)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sin conexión", @"Sin conexión")
                                        message:NSLocalizedString(@"Se ha producido un error en la conexión", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                              otherButtonTitles:nil] show];
        }
        else
        {
            [comentBox resignFirstResponder];
            comentBox.text = [NSString stringWithFormat:NSLocalizedString(@"¿Te ha gustado '%@'?", @""), eventName];
            comentBox.textColor = [UIColor lightGrayColor];
            
            [sendComentButton setTitle:NSLocalizedString(@"Enviar", @"") forState:UIControlStateNormal];
            [sendComentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            
            sendComentButton.enabled = NO;
            
            letterCountLabel.text = @"255";
            letterCountLabel.textColor = [UIColor lightGrayColor];
            letterCountLabel.backgroundColor = [UIColor clearColor];
            
            [self.tableView reloadData];
            
            [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            if (type == TZCommentTypeEvent)
            {
                [[TZTriporgManager sharedManager] createEventComment:eventId text:comentString callback:^(id result) {
                    [self performSelector:@selector(reloadCommentList:) withObject:nil];
                    
                }];
            }
            else
            {
                [[TZTriporgManager sharedManager] createLocationComment:eventId text:comentString callback:^(id result) {
                    [self performSelector:@selector(reloadCommentList:) withObject:nil];
                    
                }];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                        message:NSLocalizedString(@"Se ha producido un error", @"Se ha producido un error")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (commentsArray.count == 0)
    {
        noCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noCommentsView.backgroundColor = [UIColor whiteColor];
        
        UILabel *noCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.tableView.bounds.size.width - 30, 250)];
        noCommentLabel.text = NSLocalizedString(@"Nadie ha comentado esta actividad todavía, ¡sé el primero en hacerlo!", @"");
        noCommentLabel.numberOfLines = 0;
        noCommentLabel.textColor = [UIColor lightGrayColor];
        noCommentLabel.textAlignment = NSTextAlignmentCenter;
        noCommentLabel.backgroundColor = [UIColor clearColor];
        
        [noCommentsView addSubview:noCommentLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 170, self.tableView.bounds.size.width, 38)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [[UIImage imageNamed:@"edit"] tintImageWithColor:[UIColor lightGrayColor]];
        
        [noCommentsView addSubview:imageView];
        
        return noCommentsView;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)index
{
    if (commentsArray.count != 0)
    {
        return 0;
    }
    else
    {
        return self.tableView.bounds.size.height;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

/** Refresca el listado de Comentarios */
- (void)reloadCommentList:(id)sender
{
    if (type == TZCommentTypeEvent)
    {
        commentsArray = nil;
        [[TZTriporgManager sharedManager] getEventCommentList:eventId callback:^(id result) {
            
            commentsArray = result;
            
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        }];
    }
    else
    {
        commentsArray = nil;
        [[TZTriporgManager sharedManager] getLocationCommentList:eventId callback:^(id result) {
            
            commentsArray = result;
            
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        }];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect frame = footerCommentView.frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            frame.origin.y = 165; // new y coordinate
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration: 0.25];
            footerCommentView.frame = frame;
            [UIView commitAnimations];
        }
        if (result.height == 568)
        {
            frame.origin.y = 255; // new y coordinate
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration: 0.25];
            footerCommentView.frame = frame;
            [UIView commitAnimations];
        }
    }
    
    else
    {
        if ([versioniOS hasPrefix:@"6."])
        {
            frame.origin.y = 257; // new y coordinate
        }
        else
        {
            frame.origin.y = 317; // new y coordinate
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration: 0.25];
        footerCommentView.frame = frame;
        [UIView commitAnimations];
        
    }
    
    if ([textView.text isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"¿Te ha gustado '%@'?", @""), eventName]])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect frame = footerCommentView.frame;
    frame.origin.y = self.view.bounds.size.height - 100; // new y coordinate
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: 0.25];
    footerCommentView.frame = frame;
    [UIView commitAnimations];
    
    if ([textView.text isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"¿Te ha gustado '%@'?", @""), eventName]])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    if ([textView.text isEqualToString:@""])
    {
        textView.text = [NSString stringWithFormat:NSLocalizedString(@"¿Te ha gustado '%@'?", @""), eventName];;
        textView.textColor = [UIColor lightGrayColor];
    }
    
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    letterCount = 255 - textView.text.length;
    
    letterCountLabel.text = [NSString stringWithFormat:@"%d", letterCount];
    
    if (textView.text.length > 3)
    {
        sendComentButton.enabled = YES;
        [sendComentButton setTitle:NSLocalizedString(@"Enviar", @"") forState:UIControlStateNormal];
        [sendComentButton setTitleColor:[UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:0.9] forState:UIControlStateNormal];
        letterCountLabel.textColor = [UIColor lightGrayColor];
        
        if (textView.text.length > 255)
        {
            sendComentButton.enabled = NO;
            [sendComentButton setTitle:NSLocalizedString(@"Enviar", @"") forState:UIControlStateNormal];
            [sendComentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            letterCountLabel.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.8];
        }
    }
    else
    {
        sendComentButton.enabled = NO;
        [sendComentButton setTitle:NSLocalizedString(@"Enviar", @"") forState:UIControlStateNormal];
        [sendComentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        letterCountLabel.textColor = [UIColor lightGrayColor];
    }
    
}

- (NSString *)removedHTMLtagsFromString:(NSString *)originalString
{
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]+>" options:kNilOptions error:nil];
    });
    
    // Use reverse enumerator to delete characters without affecting indexes
    NSArray *matches = [regex matchesInString:originalString options:kNilOptions range:NSMakeRange(0, originalString.length)];
    NSEnumerator *enumerator = matches.reverseObjectEnumerator;
    
    NSTextCheckingResult *match = nil;
    NSMutableString *modifiedString = originalString.mutableCopy;
    while ((match = [enumerator nextObject]))
    {
        [modifiedString deleteCharactersInRange:match.range];
    }
    return modifiedString;
}

@end
