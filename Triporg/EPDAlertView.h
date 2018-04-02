//
//  EFAlertView.h
//  consultoria-luminica
//
//  Created by endika on 9/20/11.
//  Copyright 2011 EPD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPDAlertView : UIAlertView <UIAlertViewDelegate> {
    void (^_action)(NSUInteger index);
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message action:(void(^)(NSUInteger index))action cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
