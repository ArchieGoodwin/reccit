//
//  RCLoginFoursquareViewController.m
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCLoginFoursquareViewController.h"
#import "RCDefine.h"
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "RCWebService.h"

@interface RCLoginFoursquareViewController ()
{
    MBProgressHUD *HUD;
}

@end

@implementation RCLoginFoursquareViewController

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
    
    self.foursquare = [[BZFoursquare alloc] initWithClientID:kRCFoursquareClientID callbackURL:kRCFoursquareCallbackURL];
    self.foursquare.version = @"20111119";
    self.foursquare.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    self.foursquare.sessionDelegate = self;
    
    [self.view setBackgroundColor:kRCBackgroundView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnFoursquareTouched:(id)sender
{
    if (![self.foursquare isSessionValid]) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.foursquare startAuthorization];
    } else {
        [self.foursquare invalidateSession];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (HUD != nil) {
        [HUD hide:YES];
    }
}

- (IBAction)btnDoneTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushRate" sender:nil];
}

- (IBAction)btnSkipTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushRate" sender:nil];
}

#pragma mark -
#pragma mark BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:kRCFoursquareLoggedIn];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelFont = [UIFont boldSystemFontOfSize:12];
    HUD.labelText = @"Login Successfully!";
    
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
    [self performSegueWithIdentifier:@"PushRate" sender:nil];
    [HUD hide:YES];
}
@end
