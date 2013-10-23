//
//  RCLoginTwitterViewController.m
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCLoginTwitterViewController.h"
#import "RCDefine.h"
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "SA_OAuthTwitterEngine.h"
#import "RCWebService.h"
#import "OAToken.h"
#import "twitterHelper.h"
@interface RCLoginTwitterViewController ()
{
    MBProgressHUD *HUD;
}

@end

@implementation RCLoginTwitterViewController

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
    
    [self.view setBackgroundColor:kRCBackgroundView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnTwitterLogin:(id)sender
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	_engine.consumerKey = kRCTwitterOAuthConsumerKey;
	_engine.consumerSecret = kRCTwitterOAuthConsumerSecret;
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
	
	if (controller)
		[self presentViewController:controller animated:YES completion:^{
        }];
	else {
		[_engine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
	}
}

- (IBAction)btnDoneTouched:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }
}

- (IBAction)btnSkipTouched:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }
}

#pragma mark -
#pragma mark - Twitter Login

- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
    [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:kRCTwitterLoggedIn];
    //[[NSUserDefaults standardUserDefaults] setObject:username forKey:kRCUserName];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelFont = [UIFont boldSystemFontOfSize:12];
    HUD.labelText = @"Login Successful!";
    
    [[NSUserDefaults standardUserDefaults] setObject:[_engine getAccessToken].key forKey:@"tKey"];
    [[NSUserDefaults standardUserDefaults] setObject:[_engine getAccessToken].secret forKey:@"tSecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];


   
    
    [RCWebService authenticateTwitterWithToken:[_engine getAccessToken].key userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    

    
    
    [self performSelector:@selector(loginTwitterSuccess) withObject:nil afterDelay:1.5];
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
    [HUD hide:YES];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }
    

}

@end
