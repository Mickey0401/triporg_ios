//
//  TZTriporgManager.h
//  Triporg
//
//  Created by Endika Gutiérrez Salas on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "TZEvent.h"
#import "TZTrip.h"
#import "Reachability.h"

// API SET UP
#define kTZAPIHost          @"https://www.triporg.org" // @"http://54.228.235.78"
#define kTZAPIKey           @"a4d6f9093c2a948a6dde"   // @"2bae6167acd23ca3b257"
#define kTZAPICallPrefix    @"/api/2.0/"

extern NSString *const kTZUserLoggedIn;

typedef void(^TZRequestCallback)(id, NSError*);

@class TZUser;

@interface TZTriporgManager : NSObject <RKObjectLoaderDelegate, NSURLConnectionDelegate> {
@private
    NSMutableDictionary *_cache;
    Reachability *_reachability;
}

@property (nonatomic, readonly) Reachability *reachability;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) BOOL userLoggedIn;
@property (nonatomic, readonly) TZUser *currentUser;

+ (TZTriporgManager *)sharedManager;

// LOADER
- (void)loadObjectsAtPath:(NSString *)func
                 withParameters:(NSDictionary *)params
                         ofType:(Class)class
forceReload:(bool)forceReload
callback:(void(^)(id))callback;

// LOGIN API CALLS
- (void)checkUser:(NSString *)user callback:(void(^)(id))callback;

- (void)loginWithUser:(NSString *)user password:(NSString *)password callback:(void(^)(id))callback;

- (void)loginWithoutUser:(void(^)(id))callback;

- (void)loginWithGoogleOrFacebook:(NSString *)email name:(NSString *)name surname:(NSString *)surname gender:(NSString *)gender image:(NSString *)image city:(NSString *)city years:(NSString *)years lang:(NSString *)lang googleID:(NSString *)googleID facebookID:(NSString *)facebookID callback:(void(^)(id))callback;

- (void)registration:(NSString *)username callback:(void(^)(id))callback;

- (void)logout;

- (void)getNewUk:(void(^)(id))callback;

- (void)validateEmail:(NSString *)email callback:(void(^)(id))callback;

- (void)registerAutomaticUserWithEmail:(NSString *)email callback:(void(^)(id))callback;

- (void)expulseAutomaticUsers;

// EVENT API CALLS
- (void)getEventWithId:(NSNumber *)id callback:(void(^)(id))callback;
- (void)getLocationWithId:(NSNumber *)id callback:(void(^)(id))callback;

- (void)rateEventWithEvent:(TZEvent *)event rate:(NSNumber *)rate callback:(void(^)(id))callback;

- (void)showRestaurantsWithId:(NSNumber *)id callback:(void(^)(id))callback;

- (void)SendReportMessage:(NSNumber *)id text:(NSString *)text type:(NSString *)type callback:(void(^)(id))callback;
- (void)sendSuggestion:(NSString *)suggestion callback:(void(^)(id))callback;

- (void)nearPlacesWithLat:(NSString *)lat lon:(NSString *)lon start:(NSNumber *)start length:(NSNumber *)length callback:(void(^)(id))callback;

// CREATE TRIP API CALLS
- (void)createTripWithData:(NSDictionary *)data callback:(void(^)(id))callback;
- (void)generateFinalTrip:(NSNumber *)id callback:(void(^)(id))callback;

- (void)createRestrictionWithData:(NSDictionary *)data callback:(void(^)(id))callback;
- (void)showRestrictionListWithId:(NSNumber *)id callback:(void(^)(id))callback;
- (void)deleteRestrictionListWithId:(NSNumber *)id callback:(void(^)(id))callback;

- (void)createHotelWithId:(NSNumber *)id lat:(NSNumber *)lat lon:(NSNumber *)lon callback:(void(^)(id))callback;

// PROFILE API CALLS
- (void)showProfile:(void(^)(id))callback;

- (void)getCountries:(void(^)(id))callback;
- (void)getRegionsForCountryId:(NSNumber *)countryId callback:(void(^)(id))callback;
- (void)getCitiesForCountryId:(NSNumber *)countryId regionId:(NSNumber *)regionId callback:(void(^)(id))callback;

- (void)editUserProfileKey:(NSString *)key value:(id)value callback:(void(^)(id))callback;

- (void)showInterest:(void(^)(id))callback;
- (void)editGeneralInterestId:(NSNumber *)_id value:(NSNumber *)value callback:(void(^)(id))callback;

- (void)getLocationSpecificInterests:(void(^)(id))callback;
- (void)getActivitySpecificInterests:(void(^)(id))callback;
- (void)editActivitiesSpecificInterestsWithId:(NSNumber *)id value:(NSNumber *)value callback:(void(^)(id))callback;
- (void)editLocationSpecificInterestsWithId:(NSNumber *)id value:(NSNumber *)value callback:(void(^)(id))callback;

- (void)changePasswordWithPassword:(NSString *)password callback:(void(^)(id))callback;
- (void)forgotPasswordWithEmail:(NSString *)email callback:(void(^)(id))callback;

- (void)uploadImageWithImage:(UIImage *)image callback:(void(^)(id))callback;

// DOWNLOAD TRIP API CALLS
- (void)downloadAllTheTrip:(NSNumber *)id callback:(void(^)(id))callback;
- (void)downloadCityInfoWithId:(NSNumber *)id callback:(void(^)(id))callback;
- (void)removeCacheOfTrip:(NSNumber *)id callback:(void(^)(id))callback;

// COMMENTS API CALLS
- (void)createEventComment:(NSNumber *)id text:(NSString *)text callback:(void(^)(id))callback;
- (void)getEventCommentList:(NSNumber *)id callback:(void(^)(id))callback;
- (void)deleteEventComment:(NSNumber *)id callback:(void(^)(id))callback;

- (void)createLocationComment:(NSNumber *)id text:(NSString *)text callback:(void(^)(id))callback;
- (void)getLocationCommentList:(NSNumber *)id callback:(void(^)(id))callback;
- (void)deleteLocationComment:(NSNumber *)id callback:(void(^)(id))callback;

// CITY API CALLS
- (void)getAllCitiesWithPhotos:(void(^)(id))callback;
- (void)refreshAllCities:(void(^)(id))callback;
- (void)getCityInfoWithId:(NSNumber *)id callback:(void(^)(id))callback;

- (void)getCityUbications:(NSNumber *)id callback:(void(^)(id))callback;
- (void)getEventsOfUbication:(NSNumber *)id callback:(void(^)(id))callback;

// MAIN TRIP CALLS
- (void)getAllTripsCallback:(void(^)(id))callback;
- (void)refreshAllTripsCallback:(void(^)(id))callback;
- (void)getTripWithId:(NSNumber *)id callback:(void(^)(id))callback;
- (void)removeTripWithId:(NSNumber *)id callback:(void(^)(id))callback;

- (void)editTripWithId:(NSNumber *)id callback:(void(^)(id))callback;
- (void)setEventStatus:(TZEventStatus)status tripId:(NSNumber *)tripId eventId:(NSNumber *)eventId callback:(void(^)(id))callback;
- (void)recalculateTripWithId:(NSNumber *)id callback:(void(^)(id))callback;

- (void)shareTripWithId:(NSNumber *)id callback:(void(^)(id))callback;

// UPDATE VERSION AND MESSAGE CALLS
- (void)checkUpdatesOnAppStoreWithVersion:(NSString *)currentVersion;
- (void)sendMessageToTheUser;

// GOOGLE PLACES CALLS
- (void)PlacesPoisWithLat:(NSString *)lat lon:(NSString *)lon callback:(void(^)(id))callback;


@end
