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
#import "TestFlight.h"
#import "RCLinkedAccountsViewController.h"
#import "RCMainTabbarController.h"
#import "RCAccountViewController.h"
#import "GAI.h"
#import "RCVibeHelper.h"
#import "RCConversationsViewController.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "VibeViewController.h"
NSString *const SCSessionStateChangedNotification = @"com.Potlatch:SCSessionStateChangedNotification";

@implementation RCAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"6711549d-defd-4b9c-81c5-6f3ef099473d"];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = NO;
    // Create tracker instance.
//    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-41076620-1"];
    
    //id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-41067905-1"];
    
    //id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"vibe"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    // get current location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    _initalStoryboard = self.window.rootViewController.storyboard;

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewMessages:) name:@"vibes" object:nil];

    
    NSDictionary *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"launchOptions: %@", launchOptions);
    NSLog(@"localNotif: %@", localNotif);
    
    if (localNotif) {
        NSDictionary *itemName = [localNotif objectForKey:@"aps"];
        NSLog(@"dict: %@, aps: %@", localNotif, itemName);

        //[self getVibes];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"vibes" object:[NSNumber numberWithInt:1] userInfo:nil];


    }
    else
    {
        //[self getVibesSilent];
    }
    
    
    NSLog(@"Registering for push notifications...");
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound)];
    
    
#if TARGET_IPHONE_SIMULATOR
    
    NSString *_device_token = @"03a7e865 e2476e32 e42f28f0 c0efaf70 a778b272 7443b905 b573dc4b 9907d7a9";
    
    [[NSUserDefaults standardUserDefaults] setObject:_device_token forKey:@"device_token"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    //[mHandler saveToUserDefaults:_device_token key:@"device_token"];
#else // TARGET_IPHONE_SIMULATOR
    
    // Device specific code
    
#endif // TARGET_IPHONE_SIMULATOR

    [self clearNotifications];

    
    /*if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        self.window.clipsToBounds =YES;
        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
        
        //Added on 19th Sep 2013
        self.window.bounds = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height);
    }*/
    
    
    return YES;
}
-(void)clearNotifications
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    

    NSString *s = [[NSString stringWithFormat:@"%@", deviceToken] substringToIndex:[[NSString stringWithFormat:@"%@", deviceToken] length] - 1]; //remove last ,
    NSString * device_token = [s substringFromIndex:1];
    NSLog(@"device token: %@", device_token);
    
    [[NSUserDefaults standardUserDefaults] setObject:device_token forKey:@"device_token"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"%@", str);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
        {
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"vibes" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"vibes" object:[NSNumber numberWithInt:1] userInfo:nil];

            [self getVibes];
        }
    }
    
    //[self clearNotifications];
}

- (void)facebookReconnect
{
    NSArray *permissions = [NSArray arrayWithObjects:@"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", nil];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
    
}

-(void)renewFacebookCredentials
{
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result,
                                        NSError *error)
     {
         [self facebookReconnect];
     }];
}


-(void)showButtonForMessages
{
    [[self.window viewWithTag:5055] removeFromSuperview];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame =  CGRectMake(280,  SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 2 : 20, 35, 35);
    btn.backgroundColor = [UIColor clearColor];
    [btn setImage:[UIImage imageNamed:@"vibe_icon.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"vibe_icon.png"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"vibe_icon.png"] forState:UIControlStateSelected];

    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 23, 17, -5)];
    [btn addTarget:self action:@selector(showConversations) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 5055;
    
    [self.window addSubview:btn];
    
    
    if([self.window viewWithTag:7077] != nil)
    {
        [self.window viewWithTag:7077].hidden = NO;
        [self.window bringSubviewToFront:[self.window viewWithTag:7077]];
    }
    
}

-(void)showNewMessages:(NSNotification *)notification
{
    
    if(notification != nil)
    {
        int messages = [((NSNumber *) [notification object]) integerValue];
        
        if(messages > 0)
        {
            
            UINavigationController *navi = (UINavigationController *)self.window.rootViewController;
            for (UIViewController *controller in navi.viewControllers)
            {
               
                if ([controller isKindOfClass:[RCMainTabbarController class]]) {
                    NSLog(@"%@", ((RCMainTabbarController *)controller).selectedViewController);
                    if([controller.presentedViewController isKindOfClass:[UINavigationController class]])
                    {
                        UINavigationController *nav = (UINavigationController *)controller.presentedViewController;
                        for(UIViewController *contr1 in nav.viewControllers)
                        {
                            if([contr1 isKindOfClass:[RCConversationsViewController class]] || [contr1 isKindOfClass:[VibeViewController class]])
                            {
                                return;
                            }
                        }
                    }
                    
                    
                }
            }

            CGRect rect = CGRectMake(300, SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 0 : 19, 21, 21);
            UIView *cont = [[UIView alloc] initWithFrame:rect];
            cont.backgroundColor = [UIColor clearColor];
            
            //[cont addSubview:[self showButtonForMessages]];
            
            UIImageView *alert = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Alert.png"]];
            alert.frame = CGRectMake(0, 0, 21, 21);
            [cont addSubview:alert];
            UILabel *lblMess = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
            lblMess.backgroundColor = [UIColor clearColor];
            lblMess.textColor = [UIColor whiteColor];
            lblMess.textAlignment = NSTextAlignmentCenter;
            lblMess.font = [UIFont systemFontOfSize:11];
            lblMess.text = [NSString stringWithFormat:@"%i", messages];
            
            [cont addSubview:lblMess];
            
            cont.tag = 7077;
            [self.window addSubview:cont];
            
            //UIButton *btn = (UIButton *)[self.window viewWithTag:5055];
            //[btn setImage:nil forState:UIControlStateNormal];
            //[self.window bringSubviewToFront:btn];
        }
        else
        {
            [[self.window viewWithTag:7077] removeFromSuperview];
            
       
        }
    }
    else
    {
        [[self.window viewWithTag:7077] removeFromSuperview];
        
       
    }
    
    
    
    
    //[self performSelector:@selector(closeVibes) withObject:nil afterDelay:3];
}


-(void)getVibesSilent
{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"vibes" object:[NSNumber numberWithInt:1] userInfo:nil];

    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"] && [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] != nil)
    {
        [[RCVibeHelper sharedInstance] getConversationsFormServer:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue] completionBlock:^(int result, NSError *error) {
          
            NSLog(@"%i", result);
            
        }];
    }

}

-(void)getVibes
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
    {
        
        [[RCVibeHelper sharedInstance] getConversationsFormServer:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue] completionBlock:^(int result, NSError *error) {

            NSLog(@"getVibes getConversationsFormServer %i", result);
            [RCConversation saveDefaultContext];

            if(result > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"vibes" object:[NSNumber numberWithInt:result] userInfo:nil];

            }
          
        }];
    }

}

-(void)hideAlert
{
    [[self.window viewWithTag:7077] removeFromSuperview];
}

-(void)hideConversationButton
{
     [[self.window viewWithTag:5055] removeFromSuperview];
    
    if([self.window viewWithTag:7077] != nil)
    {
        [self.window viewWithTag:7077].hidden = YES;
    }
    
}

-(void)showConversations
{
    /*[[self.window viewWithTag:5055] removeFromSuperview];
    
    contr = [[RCConversationsViewController alloc] initWithNibName:@"RCConversationsViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:contr];
    
    [self.window.rootViewController presentViewController:nav animated:YES completion:^{
        
    }];*/
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showvibes" object:nil userInfo:nil];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        
    }
    else
    {
        [self showConversations];
    }
}


-(void)checkRoot
{
    NSLog(@"%@", [self.window.rootViewController class]);
}

- (void)resetWindowToInitialView
{
    for (UIView* view in self.window.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIViewController* initialScene = [_initalStoryboard instantiateInitialViewController];
    self.window.rootViewController = initialScene;
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
    [self saveContext];

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
        NSLog(@"%@", [controller class]);
        if ([controller isKindOfClass:[RCLoginFoursquareViewController class]]) {
            BZFoursquare *foursquare = ((RCLoginFoursquareViewController *)controller).foursquare;
            return [foursquare handleOpenURL:url];
        }
        if ([controller isKindOfClass:[RCMainTabbarController class]]) {
            NSLog(@"%@", ((RCMainTabbarController *)controller).selectedViewController);
            for (UIViewController *contrr in ((UINavigationController *)((RCMainTabbarController *)controller).selectedViewController).viewControllers)
            {
                if([contrr isKindOfClass:[RCLinkedAccountsViewController class]])
                {
                    
                    BZFoursquare *foursquare = ((RCLinkedAccountsViewController *)contrr).foursquare;
                    return [foursquare handleOpenURL:url];
                }
            }
            
            
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
    
    return [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", @"read_stream", nil] allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
       
        [self sessionStateChanged:session state:status error:error];

       
    }];
    
    
      
    
    /*return [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", @"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", @"publish_checkins", nil] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];*/
    
    /*return [FBSession openActiveSessionWithPermissions:[NSArray arrayWithObjects:@"publish_actions", @"read_friendlists", @"user_status", @"friends_status", @"user_checkins", @"friends_checkins", @"publish_checkins", nil] allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];

    }];*/
    
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
        case FBErrorDialog:{
            return @"FBErrorDialog";
        }
        default:
            return @"[Unknown]";
    }
}



- (void)showErrorAlertWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
