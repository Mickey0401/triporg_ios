//
//  TZTriporgManager.m
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TZTriporgManager.h"

#import "TZUser.h"
#import "TZCheckUser.h"
#import "TZCheckVersion.h"
#import "TZTripEvent.h"
#import "TZCity.h"
#import "TZCityWithDesc.h"
#import "TZComment.h"
#import "TZInterest.h"
#import "TZMessage.h"
#import "NSArray+Additions.h"
#import "TZKeyValue.h"
#import "TZLocation.h"
#import "TZRestaurant.h"
#import "TZForgot.h"
#import "TZUserProfileController.h"
#import "EPDAlertView.h"
#import "GooglePoi.h"
#import "TZMapCityCoord.h"

NSString *const kTZUserLoggedIn = @"kTZUserLoggedIn";

@interface TZTriporgManager () {
    NSUserDefaults *defaults;
}

- (void)loginWithUser:(TZUser *)user;
- (void)reachabilityHasChange:(Reachability *)reachability;

@end

@implementation TZTriporgManager

@synthesize currentUser = _currentUser;
@synthesize userDefaults = _userDefaults;
@synthesize reachability = _reachability;

+ (TZTriporgManager *)sharedManager
{
    static TZTriporgManager *manager = nil;
    if (!manager) {
        manager = [[TZTriporgManager alloc] init];
        
        // Initialize RestKit
        [RKObjectManager objectManagerWithBaseURL:[NSURL URLWithString:kTZAPIHost]];
        //[RKClient sharedClient].disableCertificateValidation = YES;
        [RKClient sharedClient].requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
        //[[RKClient sharedClient] setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
        
        // Load session
        NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        if (userDict) {
            [manager loginWithUser:[[TZUser alloc] initWithKeyValues:userDict]];
        }
        
        Reachability *reachability = [Reachability reachabilityWithHostName:@"www.triporg.org"];
        manager->_reachability = reachability;
        [reachability startNotifier];
        
        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(reachabilityHasChange:)
                                                     name:kReachabilityChangedNotification
                                                   object:reachability];
        // Precache types
        //[manager getAllCitiesWithPhotos:^(id r) {}];
    }
    
    return manager;
}

- (void)loginWithUser:(TZUser *)user
{
    _currentUser = user;
    _cache = [NSMutableDictionary dictionaryWithCapacity:10];
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTZUserLoggedIn object:nil];
}

- (BOOL)userLoggedIn
{
    return _currentUser != nil;
}

- (void)reachabilityHasChange:(NSNotification *)notification
{
    // NSLog(@"reachabilityHasChange: %u", _reachability.currentReachabilityStatus);
}

- (void)loadObjectsAtPath:(NSString *)func
           withParameters:(NSDictionary *)params
                   ofType:(Class)class
              forceReload:(bool)forceReload
                 callback:(void(^)(id))callback
{
    
    // Culture
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *preferredLang = [languages objectAtIndex:0];
    
    // iOS Version
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    // Device
    NSString *device;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            device = @"iphone4";
        }
        if (result.height == 568)
        {
            device = @"iphone5";
        }
    }
    else
    {
        device = @"ipad";
    }
    
    // Triporg Version
    NSString *triporgVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // Build resource path
    NSMutableString *resourcePath = [NSMutableString stringWithFormat:@"%@%@?key=%@&culture=%@&version=%@&iphone=%@&appVersion=%@", kTZAPICallPrefix, func, kTZAPIKey, preferredLang, versioniOS, device, triporgVersion];
    if (params)
    {
        for (NSString *paramKey in [params allKeys])
            [resourcePath appendFormat:@"&%@=%@", paramKey, [params objectForKey:paramKey]];
        
        [resourcePath replaceOccurrencesOfString:@" " withString:@"%20" options:0 range:NSMakeRange(0, resourcePath.length)];
    }
    
    id object = forceReload ? nil : [_cache objectForKey:resourcePath];
    
    if (object)
    {
        callback(object);
    }
    else
    {
        // NSLog(@"Load objects at path: %@", resourcePath);
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        
        [objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
            loader.userData = ^(id result) {
                if (![result isKindOfClass:[NSError class]])
                    [_cache setObject:result forKey:resourcePath];
                if (callback)
                    callback(result);
            };
            loader.delegate = self;
            //NSLog(@"%@", class);
            RKObjectMapping *mapping;// = class ? [objectManager.mappingProvider objectMappingForClass:class] : nil;
            if (!mapping) {
                @try {
                    mapping = [class objectMapping];
                }
                @catch (NSException *exception) {
                    //NSLog(@"Mapping not found for object %@", class);
                }
                
            }
            loader.objectMapping = mapping;
        }];  NSLog(@"%@", resourcePath);
    }
}

- (void)getNewUk:(void (^)(id))callback
{
    if (_currentUser.nombre == nil)
    {
        callback(nil);
    }
    else
    {
        _currentUser.id = _currentUser.user_id;
        _currentUser.nombre = nil;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _currentUser.uk, @"olduk",
                                _currentUser.id, @"user_id", nil];
        
        [self loadObjectsAtPath:@"new_user_key.json"
                 withParameters:params
                         ofType:[TZUser class]
                    forceReload:YES
                       callback:^(id resp) {
                           if ([resp isKindOfClass:[NSArray class]])
                           {
                               TZUser *user = [resp objectAtIndex:0];
                               _currentUser.uk = user.uk;
                               
                               [[NSUserDefaults standardUserDefaults] setObject:[_currentUser asKeyValueDictionary] forKey:@"user"];
                               
                               callback(resp);
                           }
                           else
                           {
                               callback(resp);
                           }
                       }];
    }
}

- (void)checkUser:(NSString *)email callback:(void (^)(id))callback
{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            nil];
    
    [self loadObjectsAtPath:@"check_user.json" withParameters:params ofType:[TZCheckUser class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZCheckUser *found = [resp objectAtIndex:0];
            NSString *encontradoUser = found.found;
            callback(encontradoUser);
        }
        else
        {
            callback(resp);
        }
    }];
    
}

- (void)loginWithUser:(NSString *)user password:(NSString *)password callback:(void(^)(id))callback
{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            user, @"username",
                            password, @"password", nil];
    
    [self loadObjectsAtPath:@"login.json" withParameters:params ofType:[TZUser class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZUser *user = [resp objectAtIndex:0];
            if ([user isKindOfClass:[TZUser class]])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[user asKeyValueDictionary] forKey:@"user"];
                [self loginWithUser:user];
            }
            callback(user);
        }
        else
        {
            callback(resp);
        }
    }];
    
}

- (void)loginWithGoogleOrFacebook:(NSString *)email name:(NSString *)name surname:(NSString *)surname gender:(NSString *)gender image:(NSString *)image city:(NSString *)city years:(NSString *)years lang:(NSString *)lang googleID:(NSString *)googleID facebookID:(NSString *)facebookID callback:(void(^)(id))callback
{
    NSDictionary *params;
    
    if (facebookID == nil)
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  email, @"email",
                  name, @"name",
                  surname, @"surname",
                  gender,@"gender",
                  image,@"image",
                  lang,@"lang",
                  city,@"city",
                  years,@"years",
                  googleID,@"googleid", nil];
    }
    else
    {
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  email, @"email",
                  name, @"name",
                  surname, @"surname",
                  gender,@"gender",
                  image,@"image",
                  lang,@"lang",
                  city,@"city",
                  years,@"years",
                  facebookID, @"facebookid", nil];
    }
    
    [self loadObjectsAtPath:@"login_with.json" withParameters:params ofType:[TZUser class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZUser *user = [resp objectAtIndex:0];
            if ([user isKindOfClass:[TZUser class]])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[user asKeyValueDictionary] forKey:@"user"];
                [self loginWithUser:user];
            }
            callback(user);
        }
        else
        {
            callback(resp);
        }
    }];
    
}

- (void)registration:(NSString *)username callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"email",
                            nil];
    
    [self loadObjectsAtPath:@"register.json" withParameters:params ofType:[TZUser class] forceReload:YES callback:^(id resp) {
        callback(resp);
    }];
}

- (void)logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _currentUser = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTZUserLogout object:nil];
}

- (void)validateEmail:(NSString *)email callback:(void (^)(id))callback
{
    if (email.length == 0)
    {
        email = @"false";
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            [NSNumber numberWithInteger:1], @"quick", nil];
    
    [self loadObjectsAtPath:@"check_email.json" withParameters:params ofType:[TZForgot class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            
            TZForgot *emailValidator = [resp objectAtIndex:0];
            callback (emailValidator.valid);
        }
        else
        {
            callback (resp);
        }
    }];
}

- (void)checkUpdatesOnAppStoreWithVersion:(NSString *)currentVersion
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"ios", @"system", nil];
    
    [self loadObjectsAtPath:@"check_version.json" withParameters:params ofType:[TZCheckVersion class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZCheckVersion *versionChecker = [resp objectAtIndex:0];
            NSString *appStoreVersion = versionChecker.version;
            
            if (![currentVersion isEqualToString:appStoreVersion] && appStoreVersion != nil) {
                
                @try {
                    
                    const id onUpdate = ^(NSUInteger index) {
                        if (index != 1)
                            return;
                        
                        NSArray *languages = [NSLocale preferredLanguages];
                        NSString *preferredLang = [languages objectAtIndex:0];
                        
                        if ([preferredLang isEqual:@"es"])
                        {
                            preferredLang = @"es";
                        }
                        else
                        {
                            preferredLang = @"en";
                        }
                        
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/%@/app/triporg/id548639464?mt=8", preferredLang]]];
                    };
                    
//                    EPDAlertView *updateAlert = [[EPDAlertView alloc] initWithTitle:NSLocalizedString(@"¡Buenas Noticias!", @"")
//                                                                            message:NSLocalizedString(@"Existe una actualización de Triporg, ¡actualízala!" , @"")
//                                                                             action:onUpdate
//                                                                  cancelButtonTitle:NSLocalizedString(@"Cancelar" , @"")
//                                                                  otherButtonTitles:NSLocalizedString(@"Disponible en App Store", @""), nil];
//                    
//                    [updateAlert show];
                    
                }
                @catch (NSException *exception) {
                    
                }
            }
        }
    }];
}

- (void)sendMessageToTheUser
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id", nil];
    
    [self loadObjectsAtPath:@"message.json" withParameters:params ofType:[TZMessage class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZMessage *message = [resp objectAtIndex:0];
            
            if ([message.msg_show isEqualToString:@"true"])
            {
                // Obtenemos el numero de version almacenada (si existe)
                
                defaults = [NSUserDefaults standardUserDefaults];
                
                NSNumber *oldmsg_version = [defaults objectForKey:@"messageVersion"];
                
                if (oldmsg_version == nil)
                {
                    oldmsg_version = [NSNumber numberWithInteger:0];
                }
                
                if ([message.logout isEqualToString:@"true"])
                {
                    @try {
                        
                        const id onUpdate = ^(NSUInteger index) {
                            
                            [self performSelector:@selector(logout) withObject:nil afterDelay:0.5];
                            
                        };
                        
                        EPDAlertView *updateAlert = [[EPDAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                                                message:message.msg
                                                                                 action:onUpdate
                                                                      cancelButtonTitle:nil
                                                                      otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
                        
                        [updateAlert show];
                        
                    }
                    @catch (NSException *exception) {
                        
                    }
                    
                }
                else if ([message.msg_version compare:oldmsg_version] == NSOrderedDescending)
                {
                    // Enseña el mensaje nuevo
                    
                    //NSLog(@"New message");
                    
                    [defaults setObject:message.msg_version forKey:@"messageVersion"];
                    [defaults synchronize];
                    
                    // Get the current date
                    NSDate *pickerDate = [NSDate date];
                    pickerDate = [pickerDate dateByAddingTimeInterval:30];
                    
                    // Schedule the notification
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = pickerDate;
                    
                    localNotification.alertBody = message.msg;
                    
                    localNotification.alertAction = nil;
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                }
                else if ([message.msg_repeat isEqualToString:@"true"])
                {
                    // Enseña el mensaje repetido
                    
                    //NSLog(@"Old message");
                    
                    [defaults setObject:message.msg_version forKey:@"messageVersion"];
                    [defaults synchronize];
                    
                    // Get the current date
                    NSDate *pickerDate = [NSDate date];
                    pickerDate = [pickerDate dateByAddingTimeInterval:30];
                    
                    // Schedule the notification
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = pickerDate;
                    
                    localNotification.alertBody = message.msg;
                    
                    localNotification.alertAction = nil;
                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                }
            }
            else
            {
                // No enseña el mensaje
                
                //NSLog(@"No message");
                
                [defaults setObject:message.msg_version forKey:@"messageVersion"];
                [defaults synchronize];
            }
        }
    }];
}

- (void)refreshAllCities:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id", nil];
    
    [self loadObjectsAtPath:@"aviable_cities.json" withParameters:params ofType:[TZCity class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            NSArray *keyValues = [resp collect:^id(TZMappedObject *o) { return [o asKeyValueDictionary]; }];
            [_userDefaults setObject:keyValues forKey:@"ciudadesPreview"];
            [_userDefaults synchronize];
        }
        callback(resp);
    }];
}

- (void)getAllCitiesWithPhotos:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id", nil];
    
    NSArray *cached = [_userDefaults objectForKey:@"ciudadesPreview"];
    if (cached)
    {
        callback([cached collect:^id(NSDictionary *t) { return [[TZCity alloc] initWithKeyValues:t]; }]);
        callback = nil;
    }
    
    [self loadObjectsAtPath:@"aviable_cities.json" withParameters:params ofType:[TZCity class] forceReload:NO callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            NSArray *keyValues = [resp collect:^id(TZMappedObject *o) { return [o asKeyValueDictionary]; }];
            [_userDefaults setObject:keyValues forKey:@"ciudadesPreview"];
            [_userDefaults synchronize];
            if (callback)
                callback(resp);
        }
        else if (!cached)
        {
            callback(resp);
        }
    }];
}

- (void)getCityInfoWithId:(NSNumber *)id_ callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",nil];
    
    [self loadObjectsAtPath:@"city.json" withParameters:params ofType:[TZCityWithDesc class] forceReload:YES callback:^(NSArray *result) {
        
        if ([result isKindOfClass:[NSArray class]])
        {
            TZCityWithDesc *cityDesc;
            cityDesc = [result objectAtIndex:0];
            cityDesc.public_transport = [cityDesc.public_transport stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br/>"];
            cityDesc.recomendations = [cityDesc.recomendations stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br/>"];
            cityDesc.information_offices = [cityDesc.information_offices stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br/>"];
            cityDesc.office_hours = [cityDesc.office_hours stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br/>"];
            
            callback(cityDesc);
        }
        else
        {
            callback (result);
        }
    }];
}

- (void)getCityUbications:(NSNumber *)id_ callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",nil];
    
    [self loadObjectsAtPath:@"city_locations.json" withParameters:params ofType:[TZLocation class] forceReload:YES callback:^(NSArray *result) {
        
        callback(result);
    }];
}

- (void)getEventsOfUbication:(NSNumber *)id_ callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",nil];
    
    [self loadObjectsAtPath:@"location_events.json" withParameters:params ofType:[TZLocation class] forceReload:YES callback:^(NSArray *result) {
        
        callback(result);
    }];
}

- (void)getAllTripsCallback:(void(^)(id))callback
{
    NSArray *tripsCached = [_userDefaults objectForKey:@"itinerario_index"];
    if (tripsCached)
    {
        NSArray *trips = [tripsCached collect:^id(NSDictionary *t) { return [[TZTrip alloc] initWithKeyValues:t]; }];
        callback(trips);
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_currentUser.uk, @"uk", _currentUser.id, @"user_id", nil];
    [self loadObjectsAtPath:@"user_trips.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            NSArray *tripsKeyValues = [resp collect:^id(TZTrip *t) { return [t asKeyValueDictionary]; }];
            [_userDefaults setObject:tripsKeyValues forKey:@"itinerario_index"];
            [_userDefaults synchronize];
            
            callback(resp);
        }
        else if (!tripsCached)
        {
            callback(resp);
        }
    }];
}

- (void)refreshAllTripsCallback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_currentUser.uk, @"uk", _currentUser.id, @"user_id", nil];
    [self loadObjectsAtPath:@"user_trips.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            NSArray *tripsKeyValues = [resp collect:^id(TZTrip *t) { return [t asKeyValueDictionary]; }];
            [_userDefaults setObject:tripsKeyValues forKey:@"itinerario_index"];
            [_userDefaults synchronize];
            
            callback(resp);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)getTripWithId:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSString *const tripKey = [NSString stringWithFormat:@"itinerario$%@", id_];
    NSDictionary *cached = [_userDefaults objectForKey:tripKey];
    if (cached && callback)
    {
        TZTrip *trip = [[TZTrip alloc] initWithKeyValues:cached];
        callback(trip);
    }
    else
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _currentUser.uk, @"uk",
                                _currentUser.id, @"user_id",
                                id_, @"id", nil];
        
        [self loadObjectsAtPath:@"trip.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(id resp) {
            if ([resp isKindOfClass:[NSArray class]])
            {
                TZTrip *trip = [resp objectAtIndex:0];
                
                if ([trip.image rangeOfString:@"default"].location == NSNotFound)
                {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    {
                        CGSize result = [[UIScreen mainScreen] bounds].size;
                        if (result.height == 480)
                        {
                            trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                        }
                        if (result.height == 568)
                        {
                            trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                        }
                    }
                    else
                    {
                        trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                }
                else
                {
                    trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:trip.image]];
                }
                
                for (TZTripEvent *eventosdeViaje in trip.events)
                {
                    if ([eventosdeViaje.image rangeOfString:@"default"].location == NSNotFound)
                    {
                        eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:[eventosdeViaje.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                    else
                    {
                        eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventosdeViaje.image]];
                    }
                }
                
                [_userDefaults setObject:[trip asKeyValueDictionary] forKey:tripKey];
                [_userDefaults synchronize];
                callback(trip);
            }
            else if (!cached)
            {
                callback(resp);
            }
        }];
    }
}

- (void)downloadAllTheTrip:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSString *const tripKey = [NSString stringWithFormat:@"itinerario$%@", id_];
    
    NSString *resolution;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            // iPhone 3GS iPhone 4 iPhone 4S
            resolution = @"960,960";
        }
        if (result.height == 568)
        {
            // iPhone 5 iPhone 5C iPhone 5S
            resolution = @"1136,1136";
        }
    }
    else
    {
        // iPad Retina
        resolution = @"2048,2048";
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"trip.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZTrip *trip = [resp objectAtIndex:0];
            
            if ([trip.image rangeOfString:@"default"].location == NSNotFound)
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    CGSize result = [[UIScreen mainScreen] bounds].size;
                    if (result.height == 480)
                    {
                        trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                    if (result.height == 568)
                    {
                        trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                }
                else
                {
                    trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                }
                
            }
            else
            {
                trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:trip.image]];
            }
            
            for (TZTripEvent *eventosdeViaje in trip.events)
            {
                if ([eventosdeViaje.image rangeOfString:@"default"].location == NSNotFound)
                {
                    eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:[eventosdeViaje.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                }
                else
                {
                    eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventosdeViaje.image]];
                }
            }
            
            NSString *mapQuestPrefix = @"%7C";
            NSString *KTZMapQuestKey = @"Fmjtd%7Cluub2da72h%2C85%3Do5-9uanuz";
            
            CGFloat maxLat = [trip.events maxWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
            CGFloat minLat = [trip.events minWithBlock:^float(TZTripEvent *ev) { return ev.lat.floatValue; }];
            CGFloat maxLng = [trip.events maxWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
            CGFloat minLng = [trip.events minWithBlock:^float(TZTripEvent *ev) { return ev.lon.floatValue; }];
            
            NSNumber *latCenter = [NSNumber numberWithFloat:(maxLat + minLat) / 2.0f];
            NSNumber *lonCenter = [NSNumber numberWithFloat:(maxLng + minLng) / 2.0f];
            
            NSString *coordCenter = [NSString stringWithFormat:@"%@,%@",latCenter,lonCenter];
            
            NSString *mapString = [NSString stringWithFormat:@"http://open.mapquestapi.com/staticmap/v4/getmap?key=%@&center=%@&zoom=15&size=%@&pois=",KTZMapQuestKey,coordCenter,resolution];
            
            NSInteger i = 1;
            
            for (TZTripEvent *eventDraw in trip.events)
            {
                NSString *position = [NSString stringWithFormat:@"%d,%@,%@%@",i,eventDraw.lat,eventDraw.lon,mapQuestPrefix];
                mapString = [NSString stringWithFormat:@"%@%@",mapString, position];
                i++;
            }
            
            NSURL *mapUrl = [NSURL URLWithString:mapString];
            NSData *mapCacheTrip = [NSData dataWithContentsOfURL:mapUrl];
            
            trip.mapCache = mapCacheTrip;
            
            NSDate *currDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd/MM/yy"];
            NSString *dateString = [dateFormatter stringFromDate:currDate];
            
            NSString *downloadKey = [NSString stringWithFormat:@"download$%@", trip.id];
            NSString *synchroKey = [NSString stringWithFormat:@"synchro$%@", trip.id];
            
            defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:dateString forKey:synchroKey];
            [defaults setObject:downloadKey forKey:downloadKey];
            [defaults synchronize];
            
            [_userDefaults setObject:[trip asKeyValueDictionary] forKey:tripKey];
            [_userDefaults synchronize];
            
            callback(trip);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)downloadCityInfoWithId:(NSNumber *)id_ callback:(void (^)(id))callback
{
    NSString *const cityKey = [NSString stringWithFormat:@"city$%@", id_];
    
    NSDictionary *cached = [_userDefaults objectForKey:cityKey];
    if (cached && callback)
    {
        TZCityWithDesc *cityS = [[TZCityWithDesc alloc] initWithKeyValues:cached];
        callback(cityS);
    }
    else
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _currentUser.uk, @"uk",
                                _currentUser.id, @"user_id",
                                id_, @"id", nil];
        
        [self loadObjectsAtPath:@"city.json" withParameters:params ofType:[TZCityWithDesc class] forceReload:YES callback:^(NSArray *result) {
            TZCityWithDesc *cityObject;
            if ([result isKindOfClass:[NSArray class]])
            {
                cityObject = [result objectAtIndex:0];
                cityObject.cacheCityImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:cityObject.image]];
                [_userDefaults setObject:[cityObject asKeyValueDictionary] forKey:cityKey];
                [_userDefaults synchronize];
                callback(cityObject);
            }
            else if (!cached)
            {
                callback(result);
            }
        }];
    }
}

- (void)removeCacheOfTrip:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"trip.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZTrip *trip = [resp objectAtIndex:0];
            
            [_userDefaults removeObjectForKey:[NSString stringWithFormat:@"itinerario$%@", id_]];
            [_userDefaults removeObjectForKey:[NSString stringWithFormat:@"city$%@", trip.city_id]];
            
            for (TZTripEvent *eventosdeViaje in trip.events)
            {
                [_userDefaults removeObjectForKey:[NSString stringWithFormat:@"evento$%@", eventosdeViaje.id]];
                [_userDefaults removeObjectForKey:[NSString stringWithFormat:@"location$%@", eventosdeViaje.id_location]];
            }
            callback(trip);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)removeTripWithId:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [_userDefaults removeObjectForKey:[NSString stringWithFormat:@"itinerario$%@", id_]];
    
    [self loadObjectsAtPath:@"delete_trip.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:callback];
}


- (void)shareTripWithId:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",
                            [NSNumber numberWithInteger:1], @"status", nil];
    
    [self loadObjectsAtPath:@"set_public_trip.json" withParameters:params ofType:[TZForgot class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZForgot *forgot;
            forgot = [resp objectAtIndex:0];
            callback(forgot);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)getEventWithId:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSString *const eventKey = [NSString stringWithFormat:@"evento$%@", id_];
    
    NSDictionary *cached = [_userDefaults objectForKey:eventKey];
    if (cached && callback)
    {
        TZEvent *eventS = [[TZEvent alloc] initWithKeyValues:cached];
        callback(eventS);
    }
    else
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _currentUser.uk, @"uk",
                                _currentUser.id, @"user_id",
                                id_, @"id", nil];
        
        [self loadObjectsAtPath:@"event.json" withParameters:params ofType:[TZEvent class] forceReload:YES callback:^(id resp) {
            TZEvent *eventS;
            if ([resp isKindOfClass:[NSArray class]])
            {
                eventS = [resp objectAtIndex:0];
                eventS.cacheEventImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventS.image]];
                [_userDefaults setObject:[eventS asKeyValueDictionary] forKey:eventKey];
                [_userDefaults synchronize];
                callback(eventS);
            }
            else if (!cached)
            {
                callback(resp);
            }
        }];
    }
}

- (void)getLocationWithId:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSString *const locationKey = [NSString stringWithFormat:@"location$%@", id_];
    
    NSDictionary *cached = [_userDefaults objectForKey:locationKey];
    if (cached && callback)
    {
        TZEvent *locationS = [[TZEvent alloc] initWithKeyValues:cached];
        callback(locationS);
    }
    else
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _currentUser.uk, @"uk",
                                _currentUser.id, @"user_id",
                                id_, @"id", nil];
        
        [self loadObjectsAtPath:@"location.json" withParameters:params ofType:[TZEvent class] forceReload:YES callback:^(id resp) {
            TZEvent *locationS;
            if ([resp isKindOfClass:[NSArray class]])
            {
                locationS = [resp objectAtIndex:0];
                locationS.cacheEventImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:locationS.image]];
                [_userDefaults setObject:[locationS asKeyValueDictionary] forKey:locationKey];
                [_userDefaults synchronize];
                callback(locationS);
            }
            else if (!cached)
            {
                callback(resp);
            }
        }];
    }
}

- (void)showRestaurantsWithId:(NSNumber *)id_ callback:(void (^)(id))callback
{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"restaurants.json" withParameters:params ofType:[TZRestaurant class] forceReload:YES callback:^(NSArray *result) {
        
        callback(result);
    }];
}

- (void)recalculateTripWithId:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"reload_trip.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(NSArray *result) {
        TZTrip *trip = nil;
        if ([result isKindOfClass:[NSArray class]] && result.count > 0)
        {
            trip = [result lastObject];
            if ([trip.image rangeOfString:@"default"].location == NSNotFound)
            {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    CGSize result = [[UIScreen mainScreen] bounds].size;
                    if (result.height == 480)
                    {
                        trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                    if (result.height == 568)
                    {
                        trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                }
                else
                {
                    trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                }
            }
            else
            {
                trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:trip.image]];
            }
            
            for (TZTripEvent *eventosdeViaje in trip.events)
            {
                if ([eventosdeViaje.image rangeOfString:@"default"].location == NSNotFound)
                {
                    eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:[eventosdeViaje.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                }
                else
                {
                    eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventosdeViaje.image]];
                }
            }
            
            NSString *const tripKey = [NSString stringWithFormat:@"itinerario$%@", trip.id];
            [_userDefaults setObject:[trip asKeyValueDictionary] forKey:tripKey];
            [_userDefaults synchronize];
        }

        callback(trip ?: result);
    }];
}

- (void)editTripWithId:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"show_events.json" withParameters:params ofType:[TZEvent class] forceReload:NO callback:^(NSArray *result) {
        
        callback(result);
    }];
}

- (void)setEventStatus:(TZEventStatus)status tripId:(NSNumber *)tripId eventId:(NSNumber *)eventId callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            tripId, @"trip_id",
                            eventId, @"id", nil];
    
    NSString *method;
    switch (status)
    {
        case TZEventStatusOut:
            method = @"not_interested.json";
            break;
        case TZEventStatusIn:
            method = @"im_in.json";
            break;
        default:
            method = @"triporg_criteria.json";
            break;
    }
    
    [self loadObjectsAtPath:method withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)editUserProfileKey:(NSString *)key value:(id)value callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            value, key, nil];
    
    @try {
        [_currentUser setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:[_currentUser asKeyValueDictionary] forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    @catch (NSException *exception) {
        //NSLog(@"Error editing user: %@", exception);
    }
    
    [self loadObjectsAtPath:@"edit_profile.json" withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)createTripWithData:(NSDictionary *)data callback:(void(^)(id))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:data];
    [params setObject:_currentUser.uk forKey:@"uk"];
    [params setObject:_currentUser.id forKey:@"user_id"];
    
    [self loadObjectsAtPath:@"new_trip.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZTrip *trip = [resp objectAtIndex:0];
            
            callback(trip);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)createRestrictionWithData:(NSDictionary *)data callback:(void(^)(id))callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:data];
    [params setObject:_currentUser.uk forKey:@"uk"];
    [params setObject:_currentUser.id forKey:@"user_id"];
    
    [self loadObjectsAtPath:@"new_appointment.json" withParameters:params ofType:[TZTripEvent class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZTripEvent *cita = [resp objectAtIndex:0];
            callback(cita);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)showRestrictionListWithId:(NSNumber *)id_ callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"trip_appointments.json" withParameters:params ofType:[TZTripEvent class] forceReload:YES callback:^(NSArray *result) {
        
        callback(result);
    }];
}

- (void)deleteRestrictionListWithId:(NSNumber *)id_ callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"delete_appointment.json" withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)createHotelWithId:(NSNumber *)id_ lat:(NSNumber *)lat lon:(NSNumber *)lon callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            lat,@"lat",
                            lon, @"lon",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"hotel.json" withParameters:params ofType:[TZTripEvent class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            callback(resp);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)generateFinalTrip:(NSNumber *)id_ callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"generate_trip.json" withParameters:params ofType:[TZTrip class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZTrip *trip = [resp objectAtIndex:0];
            
            if ([trip.image rangeOfString:@"default"].location == NSNotFound)
            {
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    CGSize result = [[UIScreen mainScreen] bounds].size;
                    if (result.height == 480)
                    {
                        trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                    if (result.height == 568)
                    {
                        trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                    }
                }
                else
                {
                    trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:[trip.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                }
            }
            else
            {
                trip.imageFinal = [NSData dataWithContentsOfURL:[NSURL URLWithString:trip.image]];
            }
            
            for (TZTripEvent *eventosdeViaje in trip.events)
            {
                if ([eventosdeViaje.image rangeOfString:@"default"].location == NSNotFound)
                {
                    eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:[eventosdeViaje.image stringByReplacingOccurrencesOfString:@"/images/" withString:@"/images/thumbnails/"]]];
                }
                else
                {
                    eventosdeViaje.cacheImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventosdeViaje.image]];
                }
            }
            
            NSString *const tripKey = [NSString stringWithFormat:@"itinerario$%@", trip.id];
            [_userDefaults setObject:[trip asKeyValueDictionary] forKey:tripKey];
            [_userDefaults synchronize];
            
            callback(trip);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)rateEventWithEvent:(TZEvent *)event rate:(NSNumber *)rate callback:(void (^)(id))callback
{
    NSString *const eventKey = [NSString stringWithFormat:@"evento$%@", event.id];
    
    event.rate = rate;
    
    [_userDefaults setObject:[event asKeyValueDictionary] forKey:eventKey];
    [_userDefaults synchronize];
    
    if (rate.integerValue != 0)
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _currentUser.uk, @"uk",
                                _currentUser.id, @"user_id",
                                event.id, @"id",
                                rate, @"value", nil];
        
        [self loadObjectsAtPath:@"rate_event.json" withParameters:params ofType:nil forceReload:YES callback:callback];
    }
}

- (void)SendReportMessage:(NSNumber *)id_ text:(NSString *)text type:(NSString *)type callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",
                            text, @"userText",
                            type, @"tipo", nil];
    
    [self loadObjectsAtPath:@"content_report.json" withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)sendSuggestion:(NSString *)suggestion callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            suggestion, @"text", nil];
    
    [self loadObjectsAtPath:@"suggest.json" withParameters:params ofType:nil forceReload:YES callback:^(id resp) {
        callback(resp);
    }];
}

- (void)nearPlacesWithLat:(NSString *)lat lon:(NSString *)lon start:(NSNumber *)start length:(NSNumber *)length callback:(void (^)(id))callback
{
    if (start == nil || length == nil)
    {
        start = [NSNumber numberWithInteger:0];
        length = [NSNumber numberWithInteger:20];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            lat, @"lat",
                            lon, @"lon",
                            start, @"start",
                            length, @"length", nil];
    
    [self loadObjectsAtPath:@"near_locations.json" withParameters:params ofType:[TZTripEvent class] forceReload:YES callback:^(id resp) {
        callback(resp);
    }];
}

- (void)PlacesPoisWithLat:(NSString *)lat lon:(NSString *)lon callback:(void (^)(id))callback
{
    NSString *googlePlacesKey = @"AIzaSyDNVOtL0Fa4Zc3exXdMFr005wxFzSan2Yc";
    
    NSString *stringPlaces = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?types=food&location=%@,%@&radius=10000&sensor=false&key=%@",lat,lon,googlePlacesKey];
    
    NSURL *urlPlaces = [NSURL URLWithString:stringPlaces];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:urlPlaces] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error)
        {
            callback (error);
        }
        else
        {
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil)
            {
                callback (localError);
                return;
            }
            
            NSMutableArray *groups = [[NSMutableArray alloc] init];
            
            // Get all object
            NSArray *items = [parsedObject valueForKeyPath:@"results"];
            NSArray *itemsForLat = [parsedObject valueForKeyPath:@"results.geometry.location"];
            
            for (NSInteger i = 0; items.count > i; i++)
            {
                GooglePoi *googlePoi = [[GooglePoi alloc] init];
                
                googlePoi.name = [[items objectAtIndex:i] objectForKey:@"name"];
                googlePoi.lat = [[itemsForLat objectAtIndex:i] objectForKey:@"lat"];
                googlePoi.lon = [[itemsForLat objectAtIndex:i] objectForKey:@"lng"];
                
                [groups addObject:googlePoi];
            }
            
            NSArray *result = groups;
            
            callback(result);
        }
    }];
}

- (void)createEventComment:(NSNumber *)id_ text:(NSString *)text callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",
                            text, @"text" ,nil];
    
    [self loadObjectsAtPath:@"comment_event_new.json" withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)getEventCommentList:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",nil];
    
    [self loadObjectsAtPath:@"comment_event_list.json" withParameters:params ofType:[TZComment class] forceReload:YES callback:^(NSArray *result) {
        
        callback(result);
    }];
}

- (void)deleteEventComment:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"comment_event_delete.json" withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)createLocationComment:(NSNumber *)id_ text:(NSString *)text callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",
                            text, @"text" ,nil];
    
    [self loadObjectsAtPath:@"comment_location_new.json" withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)getLocationCommentList:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id",nil];
    
    [self loadObjectsAtPath:@"comment_location_list.json" withParameters:params ofType:[TZComment class] forceReload:YES callback:^(NSArray *result) {
        
        callback(result);
    }];
}

- (void)deleteLocationComment:(NSNumber *)id_ callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            id_, @"id", nil];
    
    [self loadObjectsAtPath:@"comment_location_delete.json" withParameters:params ofType:nil forceReload:YES callback:callback];
}

- (void)showProfile:(void(^)(id))callback
{
    [self loadObjectsAtPath:@"profile.json"
             withParameters:@{@"uk": _currentUser.uk, @"user_id": _currentUser.id}
                     ofType:[TZUser class]
                forceReload:YES
                   callback:^(NSArray *resp) {
                       if ([resp isKindOfClass:NSArray.class])
                       {
                           TZUser *user = [resp objectAtIndex:0];
                           
                           if (user.image.length > 0)
                           {
                               user.downloadedImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.triporg.org/uploads/perfiles/images/thumbnails/%@", user.image]]];
                               _currentUser.downloadedImage = user.downloadedImage;
                           }
                           callback(user);
                       }
                   }];
}

- (void)showInterest:(void (^)(id))callback
{
    [self loadObjectsAtPath:@"interests.json"
             withParameters:@{@"uk": _currentUser.uk, @"user_id": _currentUser.id}
                     ofType:[TZUser class]
                forceReload:YES
                   callback:^(id resp) {
                       callback(resp);
                   }];
}

- (void)editGeneralInterestId:(NSNumber *)_id value:(NSNumber *)value callback:(void(^)(id))callback
{
    [self loadObjectsAtPath:@"edit_interest.json"
             withParameters:@{@"uk": _currentUser.uk, @"user_id": _currentUser.id, @"id":_id, @"value":value}
                     ofType:[TZUser class]
                forceReload:YES
                   callback:callback];
}

- (void)getCountries:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id", nil];
    
    [self loadObjectsAtPath:@"user_countries.json" withParameters:params ofType:[TZKeyValue class] forceReload:NO callback:callback];
}

- (void)getRegionsForCountryId:(NSNumber *)countryId callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            countryId, @"country_id", nil];
    
    [self loadObjectsAtPath:@"user_regions.json"
             withParameters:params
                     ofType:[TZKeyValue class]
                forceReload:NO
                   callback:callback];
}

- (void)getCitiesForCountryId:(NSNumber *)countryId regionId:(NSNumber *)regionId callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            countryId, @"country_id",
                            regionId, @"region_id", nil];
    
    [self loadObjectsAtPath:@"user_cities.json"
             withParameters:params
                     ofType:[TZKeyValue class]
                forceReload:NO
                   callback:callback];
}

- (void)getActivitySpecificInterests:(void (^)(id))callback
{
    [self loadObjectsAtPath:@"interests_specific_activity.json"
             withParameters:@{@"uk": _currentUser.uk, @"user_id": _currentUser.id}
                     ofType:[TZInterest class]
                forceReload:YES
                   callback:callback];
}

- (void)getLocationSpecificInterests:(void (^)(id))callback
{
    [self loadObjectsAtPath:@"interests_specific_location.json"
             withParameters:@{@"uk": _currentUser.uk, @"user_id": _currentUser.id}
                     ofType:[TZInterest class]
                forceReload:YES
                   callback:callback];
}

- (void)editActivitiesSpecificInterestsWithId:(NSNumber *)id value:(NSNumber *)value callback:(void(^)(id))callback
{
    [self loadObjectsAtPath:@"edit_interests_specific_activity.json"
             withParameters:@{@"uk": _currentUser.uk, @"user_id": _currentUser.id, @"id": id, @"value": value }
                     ofType:nil
                forceReload:YES
                   callback:callback];
}

- (void)editLocationSpecificInterestsWithId:(NSNumber *)id value:(NSNumber *)value callback:(void(^)(id))callback
{
    [self loadObjectsAtPath:@"edit_interests_specific_location.json"
             withParameters:@{@"uk": _currentUser.uk, @"user_id": _currentUser.id, @"id": id, @"value": value }
                     ofType:nil
                forceReload:YES
                   callback:callback];
}

- (void)changePasswordWithPassword:(NSString *)password callback:(void(^)(id))callback
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            password,@"password", nil];
    
    [self loadObjectsAtPath:@"password_change.json" withParameters:params ofType:[TZUser class] forceReload:YES callback:^(id resp) {
        if ([resp isKindOfClass:NSArray.class])
        {
            TZUser *user = [resp objectAtIndex:0];
            _currentUser.uk = user.uk;
            
            [[NSUserDefaults standardUserDefaults] setObject:[_currentUser asKeyValueDictionary] forKey:@"user"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            callback(user);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)forgotPasswordWithEmail:(NSString *)email callback:(void(^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email,@"email", nil];
    
    [self loadObjectsAtPath:@"forgot_password.json" withParameters:params ofType:[TZForgot class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZForgot *forgot;
            forgot = [resp objectAtIndex:0];
            callback(forgot);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)uploadImageWithImage:(UIImage *)image callback:(void (^)(id))callback
{
    // Culture
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *preferredLang = [languages objectAtIndex:0];
    
    // iOS Version
    NSString *versioniOS = [[UIDevice currentDevice] systemVersion];
    
    // Device
    NSString *device;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            device = @"iphone4";
        }
        if (result.height == 568)
        {
            device = @"iphone5";
        }
    }
    else
    {
        device = @"ipad";
    }
    
    // Triporg Version
    NSString *triporgVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    
    NSString *functionName = @"profile_image.json";
    
    NSString *callPrefix = [NSString stringWithFormat:@"%@%@%@", kTZAPIHost, kTZAPICallPrefix, functionName];
    
	// setting up the URL to post to
	NSString *urlString = [NSString stringWithFormat:@"%@?key=%@&culture=%@&version=%@&iphone=%@&appVersion=%@&uk=%@&user_id=%@",callPrefix, kTZAPIKey, preferredLang, versioniOS, device, triporgVersion, _currentUser.uk, _currentUser.id];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadfile\"; filename=\"profileimage.jpg\"\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error)
        {
            callback (error);
        }
        else
        {
            // NSLog(@"La foto se ha subido satisfastoriamente");
            NSString *confirmationString = @"photoUploaded";
            callback (confirmationString);
        }
    }];
}

- (void)loginWithoutUser:(void (^)(id))callback
{
    [self loadObjectsAtPath:@"automatic_user.json" withParameters:nil ofType:[TZUser class] forceReload:YES callback:^(id resp) {
        
        NSDate *currentDate = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"automaticLoginDate"];
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZUser *automaticUser = [resp objectAtIndex:0];
            automaticUser.isAutomatic = [NSNumber numberWithInteger:1];
            if ([automaticUser isKindOfClass:[TZUser class]])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[automaticUser asKeyValueDictionary] forKey:@"user"];
                [self loginWithUser:automaticUser];
            }
            callback(automaticUser);
        }
        else
        {
            callback(resp);
        }
    }];
}

- (void)registerAutomaticUserWithEmail:(NSString *)email callback:(void (^)(id))callback
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            _currentUser.uk, @"uk",
                            _currentUser.id, @"user_id",
                            email, @"email", nil];
    
    [self loadObjectsAtPath:@"automatic_user_register.json" withParameters:params ofType:[TZUser class] forceReload:YES callback:^(id resp) {
        
        if ([resp isKindOfClass:[NSArray class]])
        {
            TZUser *automaticUser = [resp objectAtIndex:0];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"automaticLoginDate"];
            
            if ([automaticUser isKindOfClass:[TZUser class]])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[automaticUser asKeyValueDictionary] forKey:@"user"];
                [self loginWithUser:automaticUser];
            }
            callback(automaticUser);
        }
        else
        {
            NSString *stringError = @"registerFailed";
            callback(stringError);
        }
    }];
}

- (void)expulseAutomaticUsers
{
    if (_currentUser.isAutomatic.integerValue == 1)
    {
        // NSLog(@"Intentando expulsar al automatic User");
        
        NSDate *currentDate = [NSDate date];
        NSDate *automaticUserEnterDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"automaticLoginDate"];
        
        // Tiempo que damos al "automaticUser" antes de expulsarlo. Por defecto 24 horas
        automaticUserEnterDate = [automaticUserEnterDate dateByAddingTimeInterval:24*60*60];
        
        if ([currentDate compare:automaticUserEnterDate] == NSOrderedDescending)
        {
            @try {
                
                const id onUpdate = ^(NSUInteger index) {
                    if (index != 1) {
                        
                        [self performSelector:@selector(logout) withObject:nil afterDelay:0.5];
                        return;
                    }
                };
                
                EPDAlertView *updateAlert = [[EPDAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"")
                                                                        message:NSLocalizedString(@"El periodo de prueba de 24 horas ha finalizado." , @"")
                                                                         action:onUpdate
                                                              cancelButtonTitle:NSLocalizedString(@"Desconectar" , @"")
                                                              otherButtonTitles:nil];
                
                [updateAlert show];
                
            }
            @catch (NSException *exception) {
                
            }
        }
    }
}

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)loader willMapData:(inout id *)mappableData
{
    //NSString *s = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:*mappableData options:0 error:nil] encoding:NSUTF8StringEncoding];
    //NSLog(@"%i %@\n %u", loader.response.statusCode, s, s.length);
    if (loader.response.statusCode == 200 && loader.objectMapping)
        return;
    
    else if (loader.response.statusCode == 401 && loader.objectMapping) {
        [self performSelector:@selector(logout) withObject:nil afterDelay:0.5];
    }
    
    void(^callback)(id) = (void(^)(id))(loader.userData);
    if (!callback)
        return;
    
    if (!loader.objectMapping) {
        callback(*mappableData);
        
    } else {
        callback([NSError errorWithDomain:@"LoadObject" code:loader.response.statusCode userInfo:*mappableData]);
    }
    
    loader.userData = nil;
    
    // Avoid restkit to map object
    *mappableData = [NSDictionary dictionary];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    // NSLog(@"objectLoader didFailWithError: %@", [error description]);
    
    void(^callback)(id) = (void(^)(id))(objectLoader.userData);
    if (callback)
        callback(error);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    // NSLog(@"%i: %u objects of type %@ has been loaded", objectLoader.response.statusCode, objects.count, objects.count ? [[objects lastObject] class] : @"undefined");
    
    void(^callback)(id) = (void(^)(id))(objectLoader.userData);
    if (callback)
        callback(objects);
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader
{
    NSError *error;
    NSDictionary *msg = [NSJSONSerialization JSONObjectWithData:objectLoader.response.body options:0 error:&error];
    
    void(^callback)(id) = (void(^)(id))(objectLoader.userData);
    if (callback)
        callback([NSError errorWithDomain:@"LoadObject" code:400 userInfo:msg]);
}

#pragma mark - RK Request delegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    if (![request isKindOfClass:[RKObjectLoader class]]) {
        void(^callback)(id) = (void(^)(id))(request.userData);
        if (callback)
            callback(response);
    }
}

@end
