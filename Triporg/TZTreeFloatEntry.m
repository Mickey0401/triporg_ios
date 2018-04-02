//
//  TZTreeFloatEntry.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 10/22/12.
//
//

#import "TZTreeFloatEntry.h"

@implementation TZTreeFloatEntry{
    CGFloat viewWidth;
}

@synthesize floatValue = _floatValue;
@synthesize userInfo;
@synthesize onChange;

- (void)fetchValueIntoObject:(id)obj {
	if (_key == nil)
		return;
    [obj setValue:[NSNumber numberWithFloat:_floatValue] forKey:_key];
}

- (void)valueChanged:(UISlider *)slider {
    _floatValue = slider.value;
}

- (void)valueHasChange:(UISlider *)slider {
    if (self.onChange)
        onChange(self);
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    UITableViewCell *cell = [super getCellForTableView:tableView controller:controller];
    
    UISlider *slider;
    if ([cell.contentView.subviews.lastObject isKindOfClass:UISlider.class])
    {
        slider = cell.contentView.subviews.lastObject;
        [slider removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    }
    else
    {
        if (viewWidth == 0.0f)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                viewWidth = 900;
            }
            else
            {
                viewWidth = 320;
            }
        }
        slider = [[UISlider alloc] initWithFrame:CGRectMake(174, 12, viewWidth - 220, 20)];
        [cell.contentView addSubview:slider];
    }
    
    slider.value = self.floatValue;
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    if (self.sections && self.sections.count && ((QSection *)self.sections[0]).elements.count)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = 0;
    
    slider.value = _floatValue;
    
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(valueHasChange:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)selected:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller indexPath:(NSIndexPath *)path {
    if (self.sections == nil)
        return;
    
    [controller displayViewControllerForRoot:self];
}

- (BOOL)needsEditing {
    return NO;
}

@end
