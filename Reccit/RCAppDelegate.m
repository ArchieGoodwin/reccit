//
//  RCAppDelegate.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCAppDelegate.h"
#import "RCCommonUtils.h"
#import "BZFoursquare.h"
#import "RCLoginFoursquareViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

NSString *const SCSessionStateChangedNotification = @"com.Potlatch:SCSessionStateChangedNotification";

@implementation RCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // get current location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    
    if ([[url scheme] hasPrefix:@"fb"]) {
        return [FBSession.activeSession handleOpenURL:url];
    }
    
    UINavigationController *navi = (UINavigationController *)self.window.rootViewController;
    for (UIViewController *controller in navi.viewControllers)
    {
        if ([controller isKindOfClass:[RCLoginFoursquareViewController class]]) {
            BZFoursquare *foursquare = ((RCLoginFoursquareViewController *)controller).foursquare;
            return [foursquare handleOpenURL:url];
        }
    }
    
    return NO;
}

#pragma mark -
#pragma mark - CLLocation delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLocation = newLocation.coordinate;
}

- (CLLocationCoordinate2D)getCurrentLocation
{
    return currentLocation;
}

#pragma mark -
#pragma mark - Facebook handler

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"FBSessionStateOpen");
            // FBSample logic
            // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
            // responsiveness when the user tags their friends.
           
            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            [cacheDescriptor prefetchAndCacheForSession:session];
            
           /* NSArray *permissions2 = [NSArray arrayWithObjects:@"publish_actions", @"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", @"publish_checkins", nil];
            
            [[FBSession activeSession] reauthorizeWithPublishPermissions:permissions2
                                                         defaultAudience:FBSessionDefaultAudienceFriends
                                                       completionHandler:^(FBSession *session, NSError *error) {
                                                           

                                                           
                                                          
                                                           
                                                           
                                                       }];
            
            */
            [self saveUserFacebookProfile];

            
        }
            break;
        case FBSessionStateClosed: {
            NSLog(@"FBSessionStateClosed");
            // FBSample logic
            // Once the user has logged out, we want them to be looking at the root view.
            
            [FBSession.activeSession closeAndClearTokenInformation];
        }
            break;
        case FBSessionStateClosedLoginFailed: {
            NSLog(@"FBSessionStateClosedLoginFailed");
            // if the token goes invalid we want to switch right back to
            // the login view, however we do it with a slight delay in order to
            // account for a race between this and the login view dissappearing
            // a moment before
        }
            break;
        default:
            break;
    }
    
   
    [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification object:session];
    
    if (error) {
        NSLog(@"%@ %@", [NSString stringWithFormat:@"Error: %@",
                         [RCAppDelegate FBErrorCodeDescription:error.code]], error.localizedDescription);
        //        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Get problem when login to Facebook"];
    }
    
    
}

- (void)saveUserFacebookProfile {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 //                 [[ITUserAPI sharedInstance] updateUserFacebookID:[user objectForKey:@"id"] onCompletion:^(int code) {
                 //                     // complete
                 //                 } orError:^(NSString *message) {
                 //                     // error
                 //                 }];
             }
         }];
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    
    /*NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      
                                      
                                      
                                       [self sessionStateChanged:session state:status error:error];
                                      
                                      
                                  
                                  }];
    
    */
    return [FBSession openActiveSessionWithPermissions:[NSArray arrayWithObjects:@"publish_actions", @"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", @"publish_checkins", nil] allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];

    }];
    
    /*return [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", @"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", @"publish_checkins", nil] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];*/
}

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        case FBErrorNativeDialog:{
            return @"FBErrorNativeDialog";
        }
        default:
            return @"[Unknown]";
    }
}

-(void)requestBasicPermissionsForFacebookAccount {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType * facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray * permissions = @[@"email"];
    NSDictionary * options = @{ACFacebookAppIdKey : @"343928219036680", ACFacebookPermissionsKey : permissions, ACFacebookAudienceKey : ACFacebookAudienceEveryone};
    //FacebookAccountManager * fbMgr = [[FacebookAccountManager alloc] init];
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray * accounts = [accountStore accountsWithAccountType:facebookAccountType];
            //fbMgr.account = [accounts lastObject];
            //fbMgr.isBasicPermissionsGranted = YES;
            //[self.accountManagers addObject:fbMgr];
            NSLog(@"granted!");
            
            
            NSArray *permissions2 = [NSArray arrayWithObjects:@"publish_actions", @"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", @"publish_checkins", nil];
             
             [[FBSession activeSession] reauthorizeWithPublishPermissions:permissions2
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
             
             
                 if(!error)
                 {
                     [self sessionStateChanged:session state:FBSessionStateOpen error:error];

                 }
             
             
             }];
             
             
            
        }
        else {
            //fbMgr.account = nil;
            //fbMgr.isBasicPermissionsGranted = NO;
            switch ([error code]) {
                case 1:
                    [self showErrorAlertWithMessage:@"Unknown error occured, try again later!"];
                    break;
                case 3:
                    [self showErrorAlertWithMessage:@"Authentication failed, try again later!"];
                    break;
                case 6:
                    //[self showErrorAlertWithMessage:@"Facebook account does not exists. Please create it in Settings and come back!"];
                    [self openSessionWithAllowLoginUI:YES];
                    
                    
                    
                    break;
                case 7:
                    [self showErrorAlertWithMessage:@"Permission request failed. You won't be able to share information to Facebook"];
                    break;
                default:
                    break;
            }
            NSLog(@"error is: %@", error);
        }
    }];
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [alertView show];
    });
}



@end
