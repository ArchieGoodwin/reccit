//
//  RCLoginViewController.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCLoginViewController.h"
#import "RCDataHolder.h"
#import "RCAppDelegate.h"
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "RCDefine.h"
#import "SA_OAuthTwitterEngine.h"
#import "RCWebService.h"
#import "OAToken.h"
#import "facebookHelper.h"
#import "ASIHTTPRequest.h"

#import "twitterHelper.h"


@interface RCLoginViewController ()
{
    MBProgressHUD *HUD;

    BOOL isFirstTime;


}

@end

@implementation RCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    
    // facebook session
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionStateChanged:) name:SCSessionStateChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFacebookSuccess) name:@"fLogin" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginTwitterSuccess) name:@"tLogin" object:nil];

    
    if([[NSUserDefaults standardUserDefaults] objectForKey:kRCFirstTimeLogin] == nil)
    {
        isFirstTime = YES;

        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kRCFirstTimeLogin];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
    else
    {
        isFirstTime = NO;

    }
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    
    if (isFirstTime) {
        isFirstTime = NO;
        
        // Check authentication
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] != nil)
        {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCTwitterLoggedIn] != nil)
            {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] != nil) {
                    [self performSegueWithIdentifier:@"PushRate" sender:nil];
                } else {
                    [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
                }
            } else {
                [self performSegueWithIdentifier:@"PushTwitter" sender:nil];
            }
        }
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCTwitterLoggedIn] != nil)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] != nil)
            {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] != nil) {
                    [self performSegueWithIdentifier:@"PushRate" sender:nil];
                } else {
                    [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
                }
            } else {
                [self performSegueWithIdentifier:@"PushFacebook" sender:nil];
            }
        }
    }
    else
    {

        //[[facebookHelper sharedInstance] getFacebookRecentCheckins];


        
        
        
        /*if([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn])
        {
            NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastDate"];
            if(!date)
            {
                date = [NSDate date];
            }
            [[facebookHelper sharedInstance] getFacebookQueryRecent:[NSDate date] completionBlock:^(BOOL result, NSError *error) {
                //upload checkins to server

                if([[facebookHelper sharedInstance] stringUserCheckins] || [[facebookHelper sharedInstance] stringFriendsCheckins])
                {
                    NSURL *userCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[[FBSession activeSession] accessTokenData] accessToken]]];
                    NSLog(@"get userCheckinRequest recent: %@", [NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[[FBSession activeSession] accessTokenData] accessToken]]);
                    __weak ASIHTTPRequest *userCheckinRequest = [ASIHTTPRequest requestWithURL:userCheckinUrl];
                    [userCheckinRequest setRequestMethod:@"POST"];
                    [userCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                    //NSString *str = [@"fb_usercheckin={\"data\":[{\"from\":{\"id\":715246241,\"name\":\"Sergey Dikarev\"},\"id\":10151385996696242,\"place\":{\"id\":276390062443754,\"location\":{\"latitude\":\"47.210743021951\",\"longitude\":\"38.932179656663\"},\"name\":\"qqqqq\"}}]}" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [userCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringUserCheckins].length]];
                    [userCheckinRequest setPostBody:[[[facebookHelper sharedInstance] stringUserCheckins] dataUsingEncoding:NSUTF8StringEncoding]];
                    [userCheckinRequest setFailedBlock:^{
                        //[self performSegueWithIdentifier:@"PushRate" sender:nil];
                        
                    }];
                    [userCheckinRequest setCompletionBlock:^{
                        NSDictionary *responseObjectUser = [NSJSONSerialization JSONObjectWithData:[userCheckinRequest responseData] options:0 error:nil];

                        NSLog(@"[userCheckinRequest responseData] recent: %@", [[NSString alloc] initWithData:[userCheckinRequest responseData] encoding:NSUTF8StringEncoding]);
                        //NSLog(@"userCheckinRequest:  %@",responseObjectUser);

                        if([[facebookHelper sharedInstance] stringFriendsCheckins])
                        {
                            NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekins,
                                                                                                  [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[[FBSession activeSession] accessTokenData] accessToken]]];
                            NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[[FBSession activeSession] accessTokenData] accessToken]]);
                            __weak ASIHTTPRequest *frCheckinRequest = [ASIHTTPRequest requestWithURL:frCheckinUrl];
                            frCheckinRequest.requestMethod = @"POST";
                            [frCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                            [frCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                            [frCheckinRequest setPostBody:[[[facebookHelper sharedInstance] stringFriendsCheckins] dataUsingEncoding:NSUTF8StringEncoding]];
                            [frCheckinRequest setCompletionBlock:^{
                                NSDictionary *responseObjectFR = [NSJSONSerialization JSONObjectWithData:[frCheckinRequest responseData] options:kNilOptions error:nil];
                                NSLog(@"[frCheckinRequest responseData] recent: %@", [[NSString alloc] initWithData:[frCheckinRequest responseData] encoding:NSUTF8StringEncoding]);

                                ///[[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];
                            }];

                            [frCheckinRequest startAsynchronous];
                        }
                        else
                        {
                            //[[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];

                        }



                    }];


                    [userCheckinRequest startAsynchronous];
                }
                else
                {
                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];

                }



            }];
        }*/




        
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self.navigationController setNavigationBarHidden:YES];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnFacebookLogin:(id)sender
{
    if (FBSession.activeSession.isOpen) {
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        //[appDelegate requestBasicPermissionsForFacebookAccount];
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
}

- (IBAction)btnTwitterLogin:(id)sender
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kRCTwitterOAuthConsumerKey;
	_engine.consumerSecret = kRCTwitterOAuthConsumerSecret;
	
	UIViewController			*controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	
	if (controller)
		[self presentViewController:controller animated:YES completion:^{
        }];
	else {
		[_engine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
	}
}

#pragma mark -
#pragma mark - Facebook Login

- (void)facebookSessionStateChanged:(NSNotification*) notification
{
    FBSession *section = (FBSession*) [notification object];
    if ([section state] == FBSessionStateOpen) {
        [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:kRCFacebookLoggedIn];
        
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelFont = [UIFont boldSystemFontOfSize:12];
        HUD.labelText = @"Login Successfully!";
        
        // Call webservice authenticate
        //NSLog(@"%@", [[FBSession activeSession] accessTokenData]);
        [RCWebService authenticateFacebookWithToken:[[[FBSession activeSession] accessTokenData]accessToken]  userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
        
        // Get facebook id to show image
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
            NSString *img = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", user.id];
            [[NSUserDefaults standardUserDefaults] setObject:img forKey:kRCUserImageUrl];
            [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:kRCUserName];
            [[NSUserDefaults standardUserDefaults] setObject:user.id forKey:kRCUserFacebookId];
            NSString *name = [NSString stringWithFormat:@"%@ %@", user.first_name, user.last_name];

            [[NSUserDefaults standardUserDefaults] setObject:name forKey:kRCUserFacebookName];


        }];
        
        //[self performSelector:@selector(loginFacebookSuccess) withObject:nil afterDelay:1.5];
    } else {
        [HUD hide:YES];
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Login failed with Facebook"];
    }
}

- (void)loginFacebookSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSLog(@"user: %@",[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]);

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCTwitterLoggedIn] != nil)
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] != nil) {
            [self performSegueWithIdentifier:@"PushRate" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
        }
    } else {
        [self performSegueWithIdentifier:@"PushTwitter" sender:nil];
    }
    [HUD hide:YES];

}

#pragma mark - 
#pragma mark - Twitter Login

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
    [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:kRCTwitterLoggedIn];
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:kRCUserName];
    
    NSString *img = [NSString stringWithFormat:@"https://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", username];
    [[NSUserDefaults standardUserDefaults] setObject:img forKey:kRCUserImageUrl];

    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelFont = [UIFont boldSystemFontOfSize:12];
    HUD.labelText = @"Login Successfully!";
    NSLog(@"%@ %@", [_engine getAccessToken].key, [_engine getAccessToken].secret);
    [[NSUserDefaults standardUserDefaults] setObject:[_engine getAccessToken].key forKey:@"tKey"];
    [[NSUserDefaults standardUserDefaults] setObject:[_engine getAccessToken].secret forKey:@"tSecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [RCWebService authenticateTwitterWithToken:[_engine getAccessToken].key userId:nil];
    
    
    

    //NSString *str=[[NSString alloc]init];
    //str =[_engine getFollowersIncludingCurrentStatus:YES];
    //NSLog(@" string is %@ ",str);
    
    //[self performSelector:@selector(loginTwitterSuccess) withObject:nil afterDelay:1.5];
}

-(void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
    NSArray *mFollowerArray = nil;
    mFollowerArray = userInfo;
    NSLog(@"mfollwers arra is %@",mFollowerArray);
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
    [HUD hide:YES];
    [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Login failed with Twitter"];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	[HUD hide:YES];
}

- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

- (void)loginTwitterSuccess
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] != nil)
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] != nil) {
            [self performSegueWithIdentifier:@"PushRate" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
        }
    } else {
        [self performSegueWithIdentifier:@"PushFacebook" sender:nil];
    }
    [HUD hide:YES];
}

@end
