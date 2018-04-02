//
//  TZCreateTripController.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZCreateTripController.h"
#import "TZTriporgManager.h"
#import "TZTripEventsTableController.h"
#import "MBProgressHUD.h"
#import "NSArray+Additions.h"
#import "NSDate+Helper.h"
#import "NSDate+Utilities.h"
#import "TZCity.h"
#import "TZTrip.h"
#import "TZTripsTableController.h"
#import "TZRestrictionListController.h"

static TZRestrictionListController *restrictionList = nil;

NSString *const kTZTripCreated = @"kTZTripCreated";

@interface TZCreateTripController () {
    NSNumber *idViaje;
    BOOL calendarActive;
    BOOL activeResctriction;
    BOOL activeHotel;
}

@end

@implementation TZCreateTripController

+ (void)rootElement:(void(^)(QRootElement *))callback
{
    QRootElement *root = [[QRootElement alloc] init];
    root.title = NSLocalizedString(@"Crear Viaje", @"");
    root.grouped = YES;
    QSection *section = [[QSection alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    QButtonElement *ciudadNombre = [[QButtonElement alloc] init];
    ciudadNombre.title = [defaults objectForKey:@"nombreCiudad"];
    ciudadNombre.enabled = NO;
    [section addElement:ciudadNombre];
    
    QRadioElement *type = [[QRadioElement alloc] initWithKey:@"type"];
    type.title = NSLocalizedString(@"Tipo de Viaje", @"");
    
    NSArray *typeNamesArray = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Ocio solo", @""), NSLocalizedString(@"Ocio con pareja", @""), NSLocalizedString(@"Ocio con niños", @""), NSLocalizedString(@"Ocio con amigos", @""), NSLocalizedString(@"Negocios solo", @""), NSLocalizedString(@"Negocios con pareja", @""), NSLocalizedString(@"Negocios con amigos", @""), NSLocalizedString(@"Otro", @""), nil];
    
    NSArray *typeValueArray = [[NSArray alloc] initWithObjects:@"ls",@"lp",@"lc",@"lf",@"bs",@"bc",@"bf",@"ot", nil];
    
    type.items = typeNamesArray;
    type.values = typeValueArray;
    
    [section addElement:type];
    [root addSection:section];
    section = [[QSection alloc] init];
    
    QDateTimeInlineElement *from = [[QDateTimeInlineElement alloc] initWithKey:@"from"];
    from.title = NSLocalizedString(@"Llegada", @"");
    from.dateValue = [NSDate dateFromString:[[NSDate date] stringWithFormat:@"yyyy-MM-dd 10:00:00"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    from.mode = UIDatePickerModeDateAndTime;
    [section addElement:from];
    
    QDateTimeInlineElement *to = [[QDateTimeInlineElement alloc] initWithKey:@"to"];
    to.title = NSLocalizedString(@"Salida", @"");
    to.dateValue = [NSDate dateFromString:[[NSDate date] stringWithFormat:@"yyyy-MM-dd 22:00:00"] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    to.mode = UIDatePickerModeDateAndTime;
    [section addElement:to];
    
    [root addSection:section];
    
    section = [[QSection alloc] init];
    
    QBooleanElement *addHotel = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Establecer Hotel", @"") BoolValue:NO];
    addHotel.controllerAction = @"hotelAdd:";
    [section addElement:addHotel];
    
    QBooleanElement *addRestrictions = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Añadir Citas", @"") BoolValue:NO];
    addRestrictions.controllerAction = @"restrictionAdd:";
    [section addElement:addRestrictions];
    
    [root addSection:section];
    
    section = [[QSection alloc] init];
    
    QBooleanElement *calendar = [[QBooleanElement alloc] initWithTitle:NSLocalizedString(@"Añadir en Calendario", @"") BoolValue:NO];
    calendar.controllerAction = @"calendarAdd:";
    [section addElement:calendar];
    
    [root addSection:section];
    
    callback(root);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    calendarActive = NO;
    activeResctriction = NO;
    activeHotel = NO;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.57 green:0.82 blue:0.11 alpha:1];
    
    for (QSection *section in self.root.sections) {
        for (QElement *element in section.elements) {
            if ([element respondsToSelector:@selector(setDelegate:)])
                [element performSelector:@selector(setDelegate:) withObject:self];
        }
    }
    
    self.quickDialogTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Continuar", @"") style:UIBarButtonItemStyleDone target:self action:@selector(createTrip:)];
}

- (void)createTrip:(id)sender
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    NSString *name = ((QEntryElement *) [self.root elementWithKey:@"name"]).textValue;
    
    //QRadioElement *cityElement = (QRadioElement *) [self.root elementWithKey:@"city"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *cityId = [defaults objectForKey:@"idCiudad"];
    
    if (!name || name.length == 0)
        name = [NSString stringWithFormat:NSLocalizedString(@"Viaje a %@", @""), [defaults objectForKey:@"nombreCiudad"]];
    
    QRadioElement *typeElement = (QRadioElement *) [self.root elementWithKey:@"type"];
    
    NSString *typeName = [typeElement.values objectAtIndex:typeElement.selected];
    
    if (typeName.length == 0) {
        typeName = @"ls";
    }
    
    NSDate *from = ((QDateTimeInlineElement *) [self.root elementWithKey:@"from"]).dateValue;
    NSDate *to = ((QDateTimeInlineElement *) [self.root elementWithKey:@"to"]).dateValue;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            name, @"trip_name",
                            cityId, @"city_id",
                            typeName, @"trip_type",
                            [dateFormatter stringFromDate:from], @"start",
                            [dateFormatter stringFromDate:to], @"end", nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.detailsLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    hud.detailsLabelText = NSLocalizedString(@"Calculando el mejor itinerario", @"");
    
    [[TZTriporgManager sharedManager] createTripWithData:params callback:^(id result) {
        
        if ([result isKindOfClass:[TZTrip class]]) {
            
            TZTrip *transitionTrip = nil;
            transitionTrip = result;
            
            idViaje = transitionTrip.id;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setObject:idViaje forKey:@"idViajeFinal"];
            [defaults setObject:from forKey:@"fechaInicioViaje"];
            [defaults setObject:to forKey:@"fechaFinalViaje"];
            
            [defaults synchronize];
     
            if (calendarActive == YES)
            {
                EKEventStore *eventStore = [[EKEventStore alloc] init];
                if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
                {
                    // the selector is available, so we must be on iOS 6 or newer
                    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (error)
                            {
                                // display error message here
                            }
                            else if (!granted)
                            {
                                // display access denied error message here
                            }
                            else
                            {
                                EKEvent *event = [EKEvent eventWithEventStore:eventStore];
                                event.title = name;
                                event.startDate = from;
                                event.endDate = to;
                                event.allDay = YES;
                                event.notes = [NSString stringWithFormat:@"%@ / %@", [dateFormatter stringFromDate:from], [dateFormatter stringFromDate:to]];
                                event.URL = [NSURL URLWithString:@"https://www.triporg.org"];
                                [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                                NSError *err;
                                [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                            }
                        });
                    }];
                }
                else
                {
                    // this code runs in iOS 4 or iOS 5
                }
            }
            
            if (activeResctriction == NO && activeHotel == NO) {
                [self performSelector:@selector(finalCreate:) withObject:nil];
            }
            else if (activeResctriction == NO && activeHotel == YES) {
                [self performSelector:@selector(goToHotel:) withObject:nil];
            }
            else if (activeResctriction == YES && activeHotel == NO) {
                [self performSelector:@selector(goToRestriction:) withObject:nil];
            }
            else if (activeResctriction == YES && activeHotel == YES) {
                [self performSelector:@selector(goToRestrictionAndHotel:) withObject:nil];
            }
            
        }
        else
        {
            NSString *errorDescription;
            if ([result isKindOfClass:[NSError class]]) {
                errorDescription = [((NSError *) result).userInfo objectForKey:@"error"];
            }
            
            if (!errorDescription) {
                errorDescription = NSLocalizedString(@"Error en la conexión", @"");
            }
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                        message:[NSString stringWithFormat:NSLocalizedString(@"Se ha producido un error: %@", @""), errorDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok" , @"")
                              otherButtonTitles:nil] show];
            
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        }
    }];
}

- (void)finalCreate:(id)sender
{
    [[TZTriporgManager sharedManager] generateFinalTrip:idViaje callback:^(id result) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kTZTripCreated object:nil];
        }];
    }];
}

- (void)goToRestriction:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    UIViewController *RestrictionListController = [storyboard instantiateViewControllerWithIdentifier:@"CitasList"];
    
    [self.navigationController pushViewController:RestrictionListController animated:YES];
}

- (void)goToHotel:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    UIViewController *hotelViewController = [storyboard instantiateViewControllerWithIdentifier:@"hotel"];
    
    [self.navigationController pushViewController:hotelViewController animated:YES];
}

- (void)goToRestrictionAndHotel:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TriporgStoryboard" bundle:nil];
    restrictionList = nil;
    restrictionList = [storyboard instantiateViewControllerWithIdentifier:@"CitasList"];
    restrictionList.hotelActive = @"YES";
    
    [self.navigationController pushViewController:restrictionList animated:YES];
}

- (void)calendarAdd:(id)sender
{
    
    if (calendarActive == NO) {
        calendarActive = YES;
    }
    else {
        calendarActive = NO;
    }
}

- (void)restrictionAdd:(id)sender
{
    
    if (activeResctriction == NO) {
        activeResctriction = YES;
    }
    else {
        activeResctriction = NO;
    }
}

- (void)hotelAdd:(id)sender
{
    
    if (activeHotel == NO) {
        activeHotel = YES;
    }
    else {
        activeHotel = NO;
    }
}

- (void)QEntryDidEndEditingElement:(QElement *)element andCell:(QEntryTableViewCell *)cell
{
    if ([element.key isEqualToString:@"from"] || [element.key isEqualToString:@"to"]) {
        QDateTimeInlineElement *fromEl = (QDateTimeInlineElement *) [self.root elementWithKey:@"from"];
        QDateTimeInlineElement *toEl = (QDateTimeInlineElement *) [self.root elementWithKey:@"to"];
        NSDate *from = [fromEl.dateValue dateByAddingTimeInterval:5*60];
        NSDate *sumafechas = [fromEl.dateValue dateByAddingTimeInterval:12*60*60];
        NSDate *to = [toEl.dateValue dateByAddingTimeInterval:-5*60];
        NSDate *from2 = [fromEl.dateValue dateByAddingTimeInterval:14*24*60*60];
        
        if ([from compare:to] == NSOrderedDescending)
        {
            if ([element.key isEqualToString:@"from"]) {
                ((QDateTimeInlineElement *) [self.root elementWithKey:@"to"]).dateValue = sumafechas;
            } else {
                ((QDateTimeInlineElement *) [self.root elementWithKey:@"from"]).dateValue = to;
                
            }
        }
        
        if ([from2 compare:to] == NSOrderedAscending)
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                        message:NSLocalizedString(@"No puedes seleccionar viajes de más de dos semanas", @"")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok" , @"")
                              otherButtonTitles:nil] show];
            
            if ([element.key isEqualToString:@"from"]) {
                ((QDateTimeInlineElement *) [self.root elementWithKey:@"to"]).dateValue = from;
            } else {
                ((QDateTimeInlineElement *) [self.root elementWithKey:@"from"]).dateValue = to;
                
            }
        }
        
        [self.quickDialogTableView reloadData];
    }
}



@end
