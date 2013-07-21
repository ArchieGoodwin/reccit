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

/*-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}*/
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        //self.edgesForExtendedLayout = UIExtendedEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = YES;
        
        CGRect frame = self.view.frame;
        frame.size.height = frame.size.height - 20;
        frame.origin.y = 20;

        self.view.frame = frame;
        //[UIView animateWithDuration:0.4 animations:^{
            [self.navigationController setNeedsStatusBarAppearanceUpdate];
        //}];

    }
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewMessages:) name:@"vibes" object:nil];

   // RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate getVibes];
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.tfSearch setPlaceholder:[NSString stringWithFormat:@"Search for keyword/place ^ %@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCCurrentCity]]];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil)
    {
        [[RCVibeHelper sharedInstance] registerUser:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue] deviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] completionBlock:^(BOOL result, NSError *error) {
            
            NSLog(@"success registerUser");
            
            
            
        }];
    }
   


    
    [self.view setBackgroundColor:kRCBackgroundView];
}


-(void)showNewMessages:(NSNotification *)notification
{
    if(notification != nil)
    {
        int messages = [((NSNumber *) [notification object]) integerValue];
        
        if(messages > 0)
        {
            CGRect rect = CGRectMake(self.imgAvatar.frame.origin.x + self.imgAvatar.frame.size.width / 2 + 4, self.imgAvatar.frame.origin.y - 4, 15, 15);
            UIView *cont = [[UIView alloc] initWithFrame:rect];
            cont.backgroundColor = [UIColor redColor];
            UILabel *lblMess = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
            lblMess.backgroundColor = [UIColor clearColor];
            lblMess.textColor = [UIColor whiteColor];
            lblMess.textAlignment = NSTextAlignmentCenter;
            lblMess.font = [UIFont systemFontOfSize:11];
            lblMess.text = [NSString stringWithFormat:@"%i", messages];
            
            [cont addSubview:lblMess];
            
            cont.tag = 7077;
            [self.view addSubview:cont];
        }
        else
        {
            [[self.view viewWithTag:7077] removeFromSuperview];
            
        }
    }
    else
    {
        [[self.view viewWithTag:7077] removeFromSuperview];

    }
    


    
    //[self performSelector:@selector(closeVibes) withObject:nil afterDelay:3];
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
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self  getLastCheckinsFromDate:date];
        
    });
    
    
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


-(void)getLastCheckinsFromDate:(NSDate *)date
{
    //Sequencer *sequencer = [[Sequencer alloc] init];
    __block int iterations = 1;
    
    int period = [[NSDate date] timeIntervalSinceDate:date];
    //period = 320000;
    
    //period = 864000;
    int numberOfDays = period / 86400;
    NSLog(@"%i %i", period, numberOfDays);
    if(numberOfDays < 1) return;
    
    NSLog(@"start query return last checkins %@", [NSDate date]);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
        [[facebookHelper sharedInstance] getFacebookUserCheckinsRecent2:iterations *period completionBlock:^(BOOL result, NSError *error) {
            if([[facebookHelper sharedInstance] stringUserCheckins])
            {
                NSURL *userCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                NSLog(@"get userCheckinRequest last: %@", [NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);

                AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:userCheckinUrl];
                [client setParameterEncoding:AFFormURLParameterEncoding];
                //[client setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                [client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringUserCheckins].length]];
                [client postPath:@"" parameters:@{@"fb_usercheckin":[[facebookHelper sharedInstance] stringUserCheckins]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"[userCheckinRequest responseData] last: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"userCheckinRequest last %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                    //completion([NSNumber numberWithBool:YES]);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"error userCheckinRequest last%@", [error description]);
                    [TestFlight passCheckpoint:[NSString stringWithFormat:@"error userCheckinRequest last %@  %@", [NSDate date], [error description]]];

                }];
                
                
            }
            
            [[facebookHelper sharedInstance] facebookQueryWithTimePagingRecent:iterations *period completionBlock:^(BOOL result, NSError *error) {
                if([[facebookHelper sharedInstance] stringFriendsCheckins])
                {
                    
                    NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekins,
                                                                [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                    NSLog(@"get frCheckinRequest last: %@", [NSString stringWithFormat:kSendFriendsChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                    
                    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:frCheckinUrl];
                    [client setParameterEncoding:AFFormURLParameterEncoding];
                    [client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                    [client postPath:@"" parameters:@{@"fb_usercheckin":[[facebookHelper sharedInstance] stringFriendsCheckins]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"[frCheckinRequest last responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                        [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest last %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"error frCheckinRequest last %@", [error description]);
                        [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest last %@  %@", [NSDate date], [error description]]];
                    }];
                    
                }
                
            }];
            
        }];

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
        
        surpsrice.querySearch = [NSString stringWithFormat:@"user=%@&type=happyhours&city=%@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[RCDataHolder getCurrentCity] stringByReplacingOccurrencesOfString:@" " withString:@"%20"] ];
        surpsrice.isHappyHour = YES;
    }
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnMenuTouched:(id)sender
{
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
