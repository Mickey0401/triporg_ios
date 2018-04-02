//
//  TZLenguageViewController.m
//  Triporg
//
//  Created by Koldo Ruiz on 22/08/13.
//
//

#import "TZLenguageViewController.h"
#import "UIColor+String.h"

@interface TZLenguageViewController ()

@end

@implementation TZLenguageViewController{
    NSUserDefaults *defaults;
    NSNumber *defaultNumber;
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Idioma", @"");
    
    defaults = [NSUserDefaults standardUserDefaults];
    defaultNumber = [defaults objectForKey:@"defaultActive"];
    
    dataArray = [[NSMutableArray alloc] init];
    
    NSArray *firstItemsArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"English", @""),NSLocalizedString(@"Español", @""),NSLocalizedString(@"Deutsch", @""),NSLocalizedString(@"Euskara", @""), NSLocalizedString(@"Defecto", @""), nil];
    
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
    [dataArray addObject:firstItemsArrayDict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of rows it should expect should be based on the section
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    NSString *cellValue = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *preferredLang = [languages objectAtIndex:0];
    
    if (defaultNumber == [NSNumber numberWithInteger:1])
    {
        if ([preferredLang isEqual:@"en"])
        {
            if (indexPath.row == 0)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if ([preferredLang isEqual:@"es"])
        {
            if (indexPath.row == 1)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if ([preferredLang isEqual:@"de"])
        {
            if (indexPath.row == 2)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if ([preferredLang isEqual:@"eu"])
        {
            if (indexPath.row == 3)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else {
        if (indexPath.row == 4)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"Después de elegir un idioma, reinicia la app para que los cambios surtan efecto.", @"");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedCell = nil;
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    selectedCell = [array objectAtIndex:indexPath.row];
    
    if ([selectedCell isEqualToString:NSLocalizedString(@"English", @"")])
    {
        defaultNumber = [NSNumber numberWithInteger:1];
        [defaults setObject:defaultNumber forKey:@"defaultActive"];
        
        [defaults removeObjectForKey:@"AppleLanguages"];
        [defaults setObject:[NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Español", @"")])
    {
        defaultNumber = [NSNumber numberWithInteger:1];
        [defaults setObject:defaultNumber forKey:@"defaultActive"];
        
        [defaults removeObjectForKey:@"AppleLanguages"];
        [defaults setObject:[NSArray arrayWithObjects:@"es", nil] forKey:@"AppleLanguages"];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Deutsch", @"")])
    {
        defaultNumber = [NSNumber numberWithInteger:1];
        [defaults setObject:defaultNumber forKey:@"defaultActive"];
        
        [defaults removeObjectForKey:@"AppleLanguages"];
        [defaults setObject:[NSArray arrayWithObjects:@"de", nil] forKey:@"AppleLanguages"];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Euskara", @"")])
    {
        defaultNumber = [NSNumber numberWithInteger:1];
        [defaults setObject:defaultNumber forKey:@"defaultActive"];
        
        [defaults removeObjectForKey:@"AppleLanguages"];
        [defaults setObject:[NSArray arrayWithObjects:@"eu", nil] forKey:@"AppleLanguages"];
    }
    else if ([selectedCell isEqualToString:NSLocalizedString(@"Defecto", @"")])
    {
        defaultNumber = [NSNumber numberWithInteger:0];
        [defaults removeObjectForKey:@"defaultActive"];
        
        [defaults removeObjectForKey:@"AppleLanguages"];
    }
    
    [defaults synchronize];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}

@end