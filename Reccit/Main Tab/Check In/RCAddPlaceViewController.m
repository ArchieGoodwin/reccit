//
//  RCAddPlaceViewController.m
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCAddPlaceViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "RCAppDelegate.h"
#import "RCDefine.h"
#import "SA_OAuthTwitterEngine.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIImageView+WebCache.h"
#import "RCListFriendViewController.h"
#import "RCLocation.h"
#import "RCPerson.h"
#import "RCWebService.h"
#import "OAToken.h"
#import <AddressBookUI/AddressBookUI.h>
#import "MGTwitterEngine.h"


#define kGSAPIAddNewPlace @"http://bizannouncements.com/Vega/services/app/appCheckin.php?user=%@&rating=%d&friends=%@&recommend=%@&comment=%@&auth=%@&name=%@&address=%@&city=%@&state=%@&zipcode=%@&country=%@&lat=%lf&long=%lf"
#define kRCAPIAddPlace @"http://bizannouncements.com/Vega/services/app/appCheckin.php"

@interface RCAddPlaceViewController ()
{
    MBProgressHUD *HUD;
    
    
    UITapGestureRecognizer *cancelGesture;
    
    BOOL isFirstTime;
}

@end

@implementation RCAddPlaceViewController

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
    self.reviewString = nil;
    self.messageVc = nil;
    //self.rateView.editable = YES;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] == nil)
    {
        // facebook session
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionStateChanged:) name:SCSessionStateChangedNotification object:nil];
    }
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    isFirstTime = TRUE;
    
    [self.view setBackgroundColor:kRCBackgroundView];
}

- (void)viewWillAppear:(BOOL)animated
{
    /*if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCTwitterLoggedIn] != nil)
    {
        [self.swTwitter setOn:YES];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] != nil)
    {
        [self.swFacebook setOn:YES];
    }*/
    
    if (isFirstTime) {
        isFirstTime = FALSE;
        
        if (!self.isAddNew) {
            self.imgLocation.hidden = NO;
            self.mapView.hidden = NO;
            self.viewInfo.hidden = NO;
            NSLog(@"%@", self.location.category);
            
            if ([self.location.category isEqualToString:@"hotel"])
            {
                [self.imgLocation setImage:[UIImage imageNamed:@"img-stay.png"]];
            } else if ([self.location.category isEqualToString:@"bar"])
            {
                [self.imgLocation setImage:[UIImage imageNamed:@"img-drink.png"]];
            } else if ([self.location.category isEqualToString:@"restaurant"])
            {
                [self.imgLocation setImage:[UIImage imageNamed:@"img-eat.png"]];
            }
            
            self.lbName.text = self.location.name;
            if(self.location.address)
            {
                self.lbAddress.text = self.location.address;

            }
            else
            {
                self.lbAddress.text = @"";
            }
            
            self.lbCity.text= self.location.city;
            if(self.location.phoneNumber)
            {
                self.lbPhone.text = [NSString stringWithFormat:@"Phone: %@", self.location.phoneNumber];

            }
            else
            {
                self.lbPhone.text = @"";
            }
            
            [self.rateView setRate:self.location.rating];
            if (self.location.recommendation) {
                self.btnLike.selected = YES;
            } else {
                self.btnUnLike.selected = NO;
            }
            
            CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
            MKCoordinateRegion region = {{0,0},{.001,.001}};
            region.center = currentLocation;
            
            MKPointAnnotation *userLocation = [[MKPointAnnotation alloc] init];
            userLocation.coordinate = currentLocation;
            [self.mapView addAnnotation:userLocation];
            
            [self.mapView setRegion:region animated:NO];
            self.mapView.showsUserLocation = YES;
            
            
        } else {
            
            
            
            self.imgLocation.hidden = YES;
            self.mapView.hidden = NO;
            self.viewInfo.hidden = YES;
            
            [self.rateView setRate:0];
            CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];

            MKPointAnnotation *userLocation = [[MKPointAnnotation alloc] init];
            userLocation.coordinate = CLLocationCoordinate2DMake(currentLocation.latitude,currentLocation.longitude);
            [self.mapView addAnnotation:userLocation];
            
            
            self.location = [[RCLocation alloc] init];
            self.location.name = self.locationName;
            self.location.latitude = currentLocation.latitude;
            self.location.longitude = currentLocation.longitude;
            
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error == nil) {
                    //            [RCDataHolder setCurrentCity:[NSString stringWithFormat:@"%@,%@", [[placemarks objectAtIndex:0] locality], [[placemarks objectAtIndex:0] country]]];
                    CLPlacemark *placemark = [placemarks objectAtIndex:0];
                    NSLog(@"%@", placemark.addressDictionary);

                    self.location.country = [placemark.addressDictionary objectForKey:@"Country"];
                    self.location.city = [placemark.addressDictionary objectForKey:@"City"];
                    self.location.state = [placemark.addressDictionary objectForKey:@"State"];

                    //self.location.address = ABCreateStringWithAddressDictionary([[placemarks objectAtIndex:0] addressDictionary], NO);

                    self.location.zipCode = [placemark.addressDictionary objectForKey:@"ZIP"];
                }
            }];
            
            MKCoordinateRegion region = {{0,0},{.001,.001}};
            region.center = CLLocationCoordinate2DMake(currentLocation.latitude, currentLocation.longitude);
            [self.mapView setRegion:region animated:NO];
            self.mapView.showsUserLocation = YES;
        }
    }
    
    
   
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"PushListFriends"])
    {
        RCListFriendViewController *listfriend = (RCListFriendViewController *)segue.destinationViewController;
        
        listfriend.fatherVc = self;
    }
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnReviewTouched:(id)sender
{
    if (self.location != nil)
    {

        
        
        
        self.reviewVc = [[RCReviewInDetailsViewController alloc] initWithNibName:@"RCReviewInDetailsViewController" bundle:nil];
        self.reviewVc.vsParrent = self;
        self.reviewVc.location = self.location;
        self.reviewVc.shouldSendImmediately = NO;
        //[self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
        
        [self presentSemiModalViewController:self.reviewVc];
    }
}

- (IBAction)btnWhereTouched:(id)sender
{
    
    
    
    
    
    //[self Publish:@"test"];
    //[self sentToTwitter:@"test"];
    
    self.messageVc = [[RCWhereAmIViewController alloc] initWithNibName:@"RCWhereAmIViewController" bundle:nil];
    self.messageVc.vsParrent = self;
    self.messageVc.shouldSendImmediately = NO;
    [self.messageVc.view setBackgroundColor:[UIColor clearColor]];
    
    [self presentSemiModalViewController:self.messageVc];
}

- (IBAction)btnCloseTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnAddFriendTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushListFriends" sender:nil];
}

- (IBAction)swFacebookChange:(id)sender
{
    RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];

    [appDelegate openSessionWithAllowLoginUI:NO];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] == nil && self.swFacebook.isOn)
    {
        if (FBSession.activeSession.isOpen) {
        } else {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate openSessionWithAllowLoginUI:YES];
        }
    }
}

- (IBAction)swTwitterChange:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCTwitterLoggedIn] == nil && self.swTwitter.isOn)
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
}


- (void)Publish:(NSString *)message {
    // Show the activity indicator.
    
    // Create the parameters dictionary that will keep the data that will be posted.
    NSMutableArray *fArray = [NSMutableArray new];
    for (RCPerson *person in self.listFriends)
    {

        [fArray addObject:person.ID];
    }
    
    
    
    
    
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    
    FBRequest *postLocRequest = [FBRequest requestForPlacesSearchAtCoordinate:currentLocation radiusInMeters:1000 resultsLimit:1 searchText:self.location.name];
    postLocRequest.session = FBSession.activeSession;
    [postLocRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if(!error)
        {
            NSLog(@"postLocRequest %@", [result objectForKey:@"data"]);
            NSArray *array = [result objectForKey:@"data"];
            if(array.count > 0)
            {
                NSDictionary *res = array[0];
                NSString *coor = [NSString stringWithFormat:@"{\"latitude\":\"%f\", \"longitude\":\"%f\"}", currentLocation.latitude, currentLocation.longitude];
                NSMutableDictionary * params = [NSMutableDictionary new];
                if(fArray.count > 0)
                {
                    params = [NSMutableDictionary dictionaryWithObjectsAndKeys: message, @"message",[fArray componentsJoinedByString:@","], @"tags",  [res objectForKey:@"id"], @"place", nil];

                }
                else
                {
                    params = [NSMutableDictionary dictionaryWithObjectsAndKeys: message, @"message", [res objectForKey:@"id"], @"place", coor, @"coordinates", nil];

                }
                
                FBRequest *postRequest = [FBRequest requestWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
                postRequest.session = [FBSession activeSession];
                
                if(![postRequest.session.permissions containsObject:@"publish_checkins"])
                {
                    [postRequest.session requestNewPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", @"publish_checkins", nil] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                        [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            
                            NSLog(@"%@", [error description]);
                            
                        }];
                    }];
                }
                else
                {
                    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        
                        NSLog(@"%@", [error description]);
                        
                    }];
                }

            }
            else
            {
                FBRequest *postRequest = [FBRequest requestForPostStatusUpdate:message];
                postRequest.session = [FBSession activeSession];
                
                
                if(![postRequest.session.permissions containsObject:@"publish_checkins"])
                {
                    [postRequest.session requestNewPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", @"publish_checkins", nil] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                        [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            
                            NSLog(@"%@", [error description]);
                            
                        }];
                    }];
                }
                else
                {
                    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        
                        NSLog(@"%@", [error description]);
                        
                    }];
                }

               
            }
            

        }
        else
        {
            NSLog(@"postLocRequest err %@", [error description]);
            
            FBRequest *postRequest = [FBRequest requestForPostStatusUpdate:message];
            postRequest.session = [FBSession activeSession];
            
            
            if(![postRequest.session.permissions containsObject:@"publish_checkins"])
            {
                [postRequest.session requestNewPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", @"publish_checkins", nil] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        
                        NSLog(@"%@", [error description]);
                        
                    }];
                }];
            }
            else
            {
                [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    
                    NSLog(@"%@", [error description]);
                    
                }];
            }

        }
        
        
    }];
    
    
   
}


-(void)sentToTwitter:(NSString *)message
{
    
    NSString *friends = @"";
    for (RCPerson *person in self.listFriends)
    {
        if ([self.listFriends indexOfObject:person] == 0) {
            friends = person.name;
        } else {
            friends = [NSString stringWithFormat:@"%@, %@", friends, person.name];
        }
    }
    if(![friends isEqualToString:@""])
    {
        message = [NSString stringWithFormat:@"%@ hanging with %@", message, friends];
    }
    
    
    NSString *value = message;
    if(message.length > 139)
    {
        value = [message substringWithRange:NSMakeRange(0, 140)];

    }

    _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
    _engine.consumerKey = kRCTwitterOAuthConsumerKey;
    _engine.consumerSecret = kRCTwitterOAuthConsumerSecret;
    [_engine setTokens:[[NSUserDefaults standardUserDefaults] objectForKey:@"tKey"] secret:[[NSUserDefaults standardUserDefaults] objectForKey:@"tSecret"]];
    UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
    
    if (controller)
        [self presentViewController:controller animated:YES completion:^{
        }];
    else {
        [_engine sendUpdate: value];
    }
    
    /*if(_engine.isAuthorized)
    {
         [_engine sendUpdate:message];
    }*/
    
    
    
   

    
}



- (IBAction)btnCheckInTouched:(id)sender
{
    

    
    if (self.isAddNew)
    {
        /*NSString *friends = @"";
        for (RCPerson *person in self.listFriends)
        {
            if ([self.listFriends indexOfObject:person] == 0) {
                friends = person.ID;
            } else {
                friends = [NSString stringWithFormat:@"%@,%@", friends, person.ID];
            }
        }
        BOOL recommend = TRUE;
        NSString *comment = @"";
        NSString *auth = @"";
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] != nil && [[NSUserDefaults standardUserDefaults] objectForKey:kRCTwitterLoggedIn] != nil)
        {
            auth = @"both";
        } else if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFacebookLoggedIn] != nil){
            auth = @"fbook";
        } else {
            auth = @"twitter";
        }
        NSString *address = @"";
        NSString *city = @"";
        NSString *state = @"";
        NSString *zipcode = @"";
        NSString *country = @"";
        CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
        NSString *urlString = [NSString stringWithFormat:
                               kGSAPIAddNewPlace,
                               [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId],
                               (int)self.rateView.rate,
                               friends,
                               recommend ? @"true":@"false",
                               comment,
                               auth,
                               self.locationName,
                               address,
                               city,
                               state,
                               zipcode,
                               country,
                               currentLocation.latitude,
                               currentLocation.longitude];
        NSLog(@"REQUEST URL: %@", urlString);
        
        // Start new request
        NSURL *url = [NSURL URLWithString:urlString];
        self.request = [ASIHTTPRequest requestWithURL:url];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.request setCompletionBlock:^{
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
            NSLog(@"%@", [responseObject description]);
            
            [self.navigationController popViewControllerAnimated:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
        [self.request setFailedBlock:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        }];
        
        [self.request startAsynchronous];*/
        /*if(!self.reviewString)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please leave a review for this place!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.tag = 101;
            [alert show];
            return;
        }*/
        if(!self.reviewString)
        {
            self.reviewString = [self makeString2];
        }
        
        if(self.swTwitter.isOn)
        {
            if(self.messageString)
            {
                [self sentToTwitter:[NSString stringWithFormat:@"%@. At %@", self.messageString, self.location.name]];
            }
            else
            {
                [self sentToTwitter:[NSString stringWithFormat:@"at %@", self.location.name]];
            }
        }
        if(self.swFacebook.isOn)
        {
            if(self.messageString)
            {
                [self Publish:[NSString stringWithFormat:@"%@. At %@", self.messageString, self.location.name]];
            }
            else
            {
                [self Publish:[NSString stringWithFormat:@"at %@", self.location.name]];
            }
        }
        NSString *urlString = [NSString stringWithFormat:@"%@?%@",kRCAPIAddPlace, self.reviewString];
        NSLog(@"REQUEST URL kRCAPIAddPlace: %@", urlString);

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];


        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        self.request = [ASIHTTPRequest requestWithURL:url];
        [self.request setRequestMethod:@"POST"];

        [self.request setCompletionBlock:^{
            
            NSLog(@"%@", [[NSString alloc] initWithData:[self.request responseData] encoding:NSUTF8StringEncoding]);
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
            NSLog(@"responseObject %@", responseObject);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Checkin successful!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.tag = 101;
            [alert show];
            
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
            
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];

        [self.request setFailedBlock:^{
            [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];

        [self.request startAsynchronous];





    } else {
        /*if(!self.reviewString)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please leave a review for this place!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.tag = 101;
            [alert show];
            return;
        }*/
        if(!self.reviewString)
        {
            self.reviewString = [self makeString2];
        }
        if(self.swTwitter.isOn)
        {
            if(self.messageString)
            {
                [self sentToTwitter:[NSString stringWithFormat:@"%@. At %@", self.messageString, self.location.name]];
            }
            else
            {
                [self sentToTwitter:[NSString stringWithFormat:@"at %@", self.location.name]];
            }
        }
        if(self.swFacebook.isOn)
        {
            if(self.messageString)
            {
                [self Publish:[NSString stringWithFormat:@"%@. At %@", self.messageString, self.location.name]];
            }
            else
            {
                [self Publish:[NSString stringWithFormat:@"at %@", self.location.name]];
            }
        }
        
        
        
        NSString *urlString = [NSString stringWithFormat:@"%@?%@",kRCAPIAddPlace, self.reviewString];
        NSLog(@"REQUEST URL kRCAPIAddPlace: %@", urlString);
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        self.request = [ASIHTTPRequest requestWithURL:url];
        [self.request setRequestMethod:@"POST"];

        [self.request setCompletionBlock:^{
            
            NSLog(@"%@", [[NSString alloc] initWithData:[self.request responseData] encoding:NSUTF8StringEncoding]);
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
            NSLog(@"responseObject %@", responseObject);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Checkin successful!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.tag = 101;
            [alert show];

            
            [self.navigationController popViewControllerAnimated:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        
        [self.request setFailedBlock:^{
            [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
        
        [self.request startAsynchronous];
        
    }
    
    
    
}


-(NSString *)makeStringWithKeyAndValue:(NSString *)key value:(NSString *)value
{
    
    return [NSString stringWithFormat:@"\"%@\":\"%@\"", key, value];
    
    
    
}

-(NSString *)makeStringWithKeyAndValue2:(NSString *)key value:(NSString *)value
{
    
    return [NSString stringWithFormat:@"\"%@\":%@", key, value];
    
    
    
}



-(NSString *)makeString2
{
    
    
    int i = (int)self.rateView.rate;
    if(i == 0)
        i = 1;
    
    //json_place={ "user":1, "name":"The Horsebox", "address":"233rd Streeth", "city":"New York", "state":"NY", "country" : "USA", "lat": "40.730094", "long": "-73.979527", "rating":"4", "recommend": true, "comment": " this place is so good"}
    
    NSArray *arr = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"user" value:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]],
                    [self makeStringWithKeyAndValue:@"name" value:self.location.name],
                    [self makeStringWithKeyAndValue2:@"rating" value:[NSString stringWithFormat:@"%i", i]],
                    [self makeStringWithKeyAndValue:@"recommend" value:self.location.recommendation ? @"true" : @"false"],
                    [self makeStringWithKeyAndValue:@"comment" value:@""],
                    [self makeStringWithKeyAndValue:@"address" value:self.location.address],
                    [self makeStringWithKeyAndValue:@"city" value:self.location.city],
                    [self makeStringWithKeyAndValue:@"state" value:self.location.state],
                    [self makeStringWithKeyAndValue:@"country" value:self.location.country],
                    [self makeStringWithKeyAndValue:@"lat" value:[NSString stringWithFormat:@"%f",self.location.latitude]],
                    [self makeStringWithKeyAndValue:@"long" value:[NSString stringWithFormat:@"%f",self.location.longitude]],
                    nil];
    
    
    
    NSString *clock = [NSString stringWithFormat:@"json_place={%@}", [arr componentsJoinedByString:@","]];
    
    
    
    NSLog(@"%@", [clock stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"%@", clock );
    
    return clock;
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
        [self.swFacebook setOn:YES];
        
        // Call webservice authenticate
        //[RCWebService authenticateFacebookWithToken:[[FBSession activeSession] accessToken] userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];

        
        [self performSelector:@selector(loginFacebookSuccess) withObject:nil afterDelay:1.5];
    } else {
        [self.swFacebook setOn:NO];
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

#pragma mark -
#pragma mark - Twitter Login




- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
    [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:kRCTwitterLoggedIn];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelFont = [UIFont boldSystemFontOfSize:12];
    HUD.labelText = @"Login Successfully!";
    
    
    
    [[NSUserDefaults standardUserDefaults] setObject:[_engine getAccessToken].key forKey:@"tKey"];
    [[NSUserDefaults standardUserDefaults] setObject:[_engine getAccessToken].secret forKey:@"tSecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Call Webservice
    [RCWebService authenticateTwitterWithToken:[_engine getAccessToken].key userId:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];

    [self performSelector:@selector(loginTwitterSuccess) withObject:nil afterDelay:1.5];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
    [HUD hide:YES];
    [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Login failed with Twitter"];
    
    [self.swTwitter setOn:NO];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	[HUD hide:YES];
    [self.swTwitter setOn:NO];
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
    
    
     //[_engine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
    /*if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }*/
}

#pragma mark -
#pragma mark - TextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    cancelGesture = [UITapGestureRecognizer new];
    [cancelGesture addTarget:self action:@selector(backgroundTouched:)];
    [self.view addGestureRecognizer:cancelGesture];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = -150;
        self.view.frame = frame;
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (cancelGesture) {
        [self.view removeGestureRecognizer:cancelGesture];;
        cancelGesture = nil;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
}

-(void) backgroundTouched:(id) sender {
    //[self.tvReview resignFirstResponder];
}

@end
