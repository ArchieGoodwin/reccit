//
//  RCHomeViewController.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCHomeViewController.h"
#import "RCDefine.h"
#import "UIImageView+WebCache.h"
#import "RCAppDelegate.h"
#import <AddressBook/AddressBook.h>
#import "RCSearchViewController.h"
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "RCDataHolder.h"
#import "RCSurpriseViewController.h"
#import "RCVibeHelper.h"
#import "RCConversationsViewController.h"
#import "RCVibeHelper.h"
#import "RCWebService.h"
#import "Sequencer.h"
#import "facebookHelper.h"
#import "AFNetworking.h"
#import "TestFlight.h"


#define SAVEFRIENDSLINK @"http://reccit.elasticbeanstalk.com/Authentication_deploy/Auth.svc/SaveFriends?oauth_token=%@&type=facebook&facebookid=%@"


@interface RCHomeViewController ()

@end

@implementation RCHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
    [appDelegate showButtonForMessages];
    
    
    //[self performSelector:@selector(testMe) withObject:nil afterDelay:5];

}

-(void)testMe
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"vibes" object:[NSNumber numberWithInt:30] userInfo:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
    
    //test!!!!!
    //[RCWebService authenticateFoursquareWithToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"4stoken"] userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];

    
    
    //viewDidload
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
        //}];
        
    }
    
  


   // RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
   // [appDelegate getVibes];
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.tfSearch setPlaceholder:[NSString stringWithFormat:@"Search for keyword/place ^ %@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCCurrentCity]]];

    
    [self.view setBackgroundColor:kRCBackgroundView];
}



-(void)closeVibes
{
     [[self.view viewWithTag:7077] removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
 
    
    
    [super viewWillAppear: animated];
 
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastDate"];
    if(date == nil)
    {
        date = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self  getLastCheckinsFromDate:date];
        
    //});
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if ([RCDataHolder getCurrentCity] == nil) {
        dispatch_async(dispatch_get_main_queue(),^{
            [self loadCurrentCity];

        });
    }
    
    
   
    //[self getVibes];
    
    [self.navigationController setNavigationBarHidden:YES];
}


-(void)saveFriends
{
    
     NSURL *saveF = [NSURL URLWithString:[NSString stringWithFormat:SAVEFRIENDSLINK, [[[FBSession activeSession] accessTokenData]accessToken] , [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
    NSLog(@"save friends link %@", [NSString stringWithFormat:SAVEFRIENDSLINK, [[[FBSession activeSession] accessTokenData]accessToken] , [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:saveF];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"save friends success: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error save friends  %@", [error description]);

    }];
    
    [operation start];
}

-(void)getLastCheckinsFromDate:(NSDate *)date
{
    //Sequencer *sequencer = [[Sequencer alloc] init];
    __block int iterations = 1;
    
    NSInteger period = [[NSDate date] timeIntervalSinceDate:date];
    
    //period = 86700;
    NSInteger numberOfDays = period / 86400;
    NSLog(@"%i %i", period, numberOfDays);
    
    
    
    
    if(numberOfDays < 1) return;
    
    if (FBSession.activeSession.isOpen) {
   
    } else {
        //HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
    }
    
    
    NSLog(@"start query return last checkins %@", [NSDate date]);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   

    [self saveFriends];

    
    
    Sequencer *sequencer = [[Sequencer alloc] init];
    
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        
        [[facebookHelper sharedInstance] getFacebookUserCheckinsRecent2:iterations *period completionBlock:^(BOOL result, NSError *error) {
            if([[facebookHelper sharedInstance] userCheckinsArray])
            {
                NSLog(@"userCheckinsArray last %@", [[facebookHelper sharedInstance] userCheckinsArray]);
                NSURL *userCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendUserChekinsDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                NSLog(@"get recent userCheckinRequest: %@", [NSString stringWithFormat:kSendUserChekinsDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                
                AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:userCheckinUrl];
                [client setParameterEncoding:AFJSONParameterEncoding];
                [client postPath:@"" parameters:@{@"data":[[facebookHelper sharedInstance] userCheckinsArray]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"[userCheckinRequest responseData] last: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                    
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"userCheckinRequest last %@ %@ with count %i", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[facebookHelper sharedInstance] userCheckinsArray].count]];
                    
                    completion([NSNumber numberWithBool:YES]);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"error userCheckinRequest last error for user %@ = %@",[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [error description]);
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"error userCheckinRequest last error for user %@ = %@",[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [error description]]];
                    completion([NSNumber numberWithBool:YES]);
                }];
                
            }
            else
            {
                completion([NSNumber numberWithBool:YES]);

            }
            
            
        }];
    }];
    
    [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
        [[facebookHelper sharedInstance] facebookQueryWithTimePagingRecent:iterations *period completionBlock:^(BOOL result, NSError *error) {
            if([[facebookHelper sharedInstance] friendsCheckinsArray])
            {
                NSLog(@"friendsCheckinsArray last %@", [[facebookHelper sharedInstance] friendsCheckinsArray]);
                
                NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                            [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                NSLog(@"get frCheckinRequest last: %@", [NSString stringWithFormat:kSendFriendsChekinsDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                
                AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:frCheckinUrl];
                [client setParameterEncoding:AFJSONParameterEncoding];
                [client postPath:@"" parameters:@{@"data":[[facebookHelper sharedInstance] friendsCheckinsArray]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"[frCheckinRequest last responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest last %@ %@ with count %i", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[facebookHelper sharedInstance] friendsCheckinsArray].count]];
                    completion([NSNumber numberWithBool:YES]);

                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"error frCheckinRequest last error for user %@ = %@",[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [error description]);
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest last error for user %@ = %@",[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [error description]]];
                    completion([NSNumber numberWithBool:YES]);

                }];
                
            }
            else
            {
                completion([NSNumber numberWithBool:YES]);
                
            }
            
        }];
        
    }];
    
    [sequencer run];

    

}






- (void)loadCurrentCity
{
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil) {
            //            [RCDataHolder setCurrentCity:[NSString stringWithFormat:@"%@,%@", [[placemarks objectAtIndex:0] locality], [[placemarks objectAtIndex:0] country]]];
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@", placemark.addressDictionary);
            [RCDataHolder setPlacemark:placemark];
            [RCDataHolder setCurrentCity:[[placemarks objectAtIndex:0] locality]];
            //self.location.address = ABCreateStringWithAddressDictionary([[placemarks objectAtIndex:0] addressDictionary], NO);
            

        }
        //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];
    
    
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    
    
    if ([segue.identifier isEqualToString:@"PushSearch"])
    {
        RCSearchViewController *search = (RCSearchViewController *)segue.destinationViewController;
        
        search.categoryName = sender;
    }
    
    if ([segue.identifier isEqualToString:@"PushSurprise"])
    {
        RCSurpriseViewController *surpsrice = (RCSurpriseViewController *)segue.destinationViewController;
        //#define kRCAPICheckInGetLocationArroundDOTNET  @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/GetFactual?userfbid=%@&city=%@&type=%@&latitude=%f&longitude=%f"

        surpsrice.querySearch = [NSString stringWithFormat:@"userfbid=%@&type=happyhour&city=%@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[RCDataHolder getCurrentCity] stringByReplacingOccurrencesOfString:@" " withString:@"%20"] ];
        surpsrice.isHappyHour = YES;
    }
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnMenuTouched:(id)sender
{
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
    
    UIButton *btn = (UIButton *)sender;
    NSString *category = @"";
    
    switch (btn.tag) {
        case 1001:
            category = @"restaurant";
            break;
        case 1002:
            category = @"bar";
            break;
        case 1003:
            category = @"hotel";
            break;
        case 1004:
            [self performSegueWithIdentifier:@"PushSurprise" sender:category];
            return;
        default:
            break;
    }
    [self performSegueWithIdentifier:@"PushSearch" sender:category];
}

@end
