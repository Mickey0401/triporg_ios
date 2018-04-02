//
//  TZTreeFloatEntry.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 10/22/12.
//
//

#import <QuickDialog.h>

@interface TZTreeFloatEntry : QLabelElement <QuickDialogEntryElementDelegate>

@property(nonatomic, assign) float floatValue;

@property (nonatomic, retain) id userInfo;
@property(nonatomic, copy) void(^onChange)(TZTreeFloatEntry *);

@property(nonatomic, strong) NSMutableArray *sections;

@end
