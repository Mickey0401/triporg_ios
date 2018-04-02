//
//  EFAlertView.m
//  consultoria-luminica
//
//  Created by endika on 9/20/11.
//  Copyright 2011 EPD. All rights reserved.
//

#import "EPDAlertView.h"

@implementation EPDAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message action:(void(^)(NSUInteger index))action cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    if (self) {
        _action = action;
    }
    return self;
}

#pragma mark - Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_action)
        _action(buttonIndex);
}

@end
