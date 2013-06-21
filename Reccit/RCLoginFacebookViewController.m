//
//  RCLoginFacebookViewController.m
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCLoginFacebookViewController.h"
#import "MBProgressHUD.h"
#import "RCAppDelegate.h"
#import "RCCommonUtils.h"
#import "RCDefine.h"
#import "RCWebService.h"

@interface RCLoginFacebookViewController ()
{
    MBProgressHUD *HUD;
}

@end

@implementation RCLoginFacebookViewController

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
    

    
    [self.view setBackgroundColor:kRCBackgroundView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnFacebookLogin:(id)sender
{
    if (FBSession.activeSession.isOpen) {
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
}

- (IBAction)btnDoneTouched:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }
}

- (IBAction)btnSkipTouched:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
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
        HUD.labelText = @"Login Successful!";
        
        // Call webservice authenticate
        
       // [RCWebService authenticateFacebookWithTokenAndSecret:[[[FBSession activeSession] accessTokenData] accessToken] secret:@"c32e6127f6d751088a31df11fcf3e2a6"];
        
        [RCWebService authenticateFacebookWithToken:[[[FBSession activeSession] accessTokenData] accessToken]  userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];

        [self performSelector:@selector(loginFacebookSuccess) withObject:nil afterDelay:1.5];
    } else {
        [HUD hide:YES];
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Login failed with Facebook"];
    }
}



- (void)loginFacebookSuccess
{
    [HUD hide:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }
}

@end
