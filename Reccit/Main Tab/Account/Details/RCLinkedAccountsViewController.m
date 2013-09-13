//
//  RCLinkedAccountsViewController.m
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCLinkedAccountsViewController.h"
#import "UIImageView+WebCache.h"
#import "RCDefine.h"
#import "RCCommonUtils.h"
#import "MBProgressHUD.h"
#import "RCAppDelegate.h"
#import "RCWebService.h"
#import "OAToken.h"

@interface RCLinkedAccountsViewController ()
{
    MBProgressHUD *HUD;
}

@end

@implementation RCLinkedAccountsViewController

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



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
        
        //}];
        
    }
	// Do any additional setup after loading the view.
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        
        self.foursquare = [[BZFoursquare alloc] initWithClientID:kRCFoursquareClientID callbackURL:kRCFoursquareCallbackURL];
        self.foursquare.version = @"20111119";
        self.foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        self.foursquare.sessionDelegate = self;
        
        

        
        self.btnFoursquareUpdate.hidden = NO;
        self.imgFoursquareConnect.hidden = YES;
    } else {
        self.btnFoursquareUpdate.hidden = YES;
        self.imgFoursquareConnect.hidden = NO;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] == nil)
    {
        self.imgFacebookConnect.hidden = YES;
        self.btnFacebookUpdate.hidden = NO;
    } else {
        self.imgFacebookConnect.hidden = NO;
        self.btnFacebookUpdate.hidden = YES;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCTwitterLoggedIn] == nil) {
        self.imgTwitterConnect.hidden = YES;
        self.btnTwitterUpdate.hidden = NO;
    } else {
        self.imgTwitterConnect.hidden = NO;
        self.btnTwitterUpdate.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (HUD != nil) {
        [HUD hide:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button

- (IBAction)btnBackTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnFoursquareTouched:(id)sender
{
    if (![self.foursquare isSessionValid]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.foursquare startAuthorization];
    } else {
        [self.foursquare invalidateSession];
    }
}


- (IBAction)btnFacebookLogin:(id)sender
{
    if (FBSession.activeSession.isOpen) {
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
}

- (IBAction)btnLogOut:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCFirstTimeLogin];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCFacebookLoggedIn];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCTwitterLoggedIn];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserImageUrl];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserName];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserFacebookId];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserId];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCFoursquareLoggedIn];

    

    [[NSUserDefaults standardUserDefaults]  synchronize];
    
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate resetWindowToInitialView];
    
}

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
        
        
        
        self.imgFacebookConnect.hidden = NO;
        self.btnFacebookUpdate.hidden = YES;
        // Call webservice authenticate
        //NSLog(@"%@", [[FBSession activeSession] accessTokenData]);
        [RCWebService authenticateFacebookWithToken:[[[FBSession activeSession] accessTokenData]accessToken]  userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
        

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
    
    self.imgTwitterConnect.hidden = NO;
    self.btnTwitterUpdate.hidden = YES;
    
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
}

#pragma mark -
#pragma mark - BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:kRCFoursquareLoggedIn];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelFont = [UIFont boldSystemFontOfSize:12];
    HUD.labelText = @"Login Successfully!";
    
    self.imgFoursquareConnect.hidden = NO;
    self.btnFoursquareUpdate.hidden = YES;
    
    // Call Webservice
    
    [RCWebService authenticateFoursquareWithToken:foursquare.accessToken userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];

    
    [self performSelector:@selector(loginFoursquareSuccess) withObject:nil afterDelay:1.5];
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    [HUD hide:YES];
    [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Login failed with Foursquare"];
}

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)loginFoursquareSuccess
{
    [HUD hide:YES];
}

@end
