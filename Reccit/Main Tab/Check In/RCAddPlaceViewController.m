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
#import "RCVibeHelper.h"
#import "RCMapAnnotation.h"
#import "RCMapAnnotationView.h"
#import <MapKit/MapKit.h>
#import "RCAppDelegate.h"
#import "AFNetworking.h"
#import "RCDataHolder.h"
#define kGSAPIAddNewPlace @"http://bizannouncements.com/Vega/services/app/appCheckin.php?user=%@&rating=%d&friends=%@&recommend=%@&comment=%@&auth=%@&name=%@&address=%@&city=%@&state=%@&zipcode=%@&country=%@&lat=%lf&long=%lf"
#define kRCAPIAddPlace @"http://bizannouncements.com/Vega/services/app/appCheckin.php"
#define kRCAPIAddPlaceDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/checkin/checkin.svc/UpdateReview"

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


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(showVibe) withObject:nil afterDelay:0.3];
    
}

-(void)showVibe
{
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate showButtonForMessages];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    //viewDidload
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
      
        //}];
        
    }
    else
    {
        CGRect frame = self.downView.frame;
        frame.origin.y = frame.origin.y + 54;
        self.downView.frame = frame;
        
    }
	// Do any additional setup after loading the view.
    _imgLike.hidden = YES;
    _lblReccits.hidden = YES;
    
    
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

- (void)centerMap2{
    
    if([_mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id <MKAnnotation> annotation in _mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = 0.003; // Add a little extra space on the sides
    region.span.longitudeDelta = 0.003; // Add a little extra space on the sides
    
    region = [_mapView regionThatFits:region];
    [_mapView setRegion:region animated:YES];
    
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
            
            self.location.type = self.location.category;
            if ([self.location.category isEqualToString:@"hotel"])
            {
                [self.imgLocation setImage:[UIImage imageNamed:@"sleep_type.png"]];
            } else if ([self.location.category isEqualToString:@"bar"])
            {
                [self.imgLocation setImage:[UIImage imageNamed:@"drink_type.png"]];
            } else if ([self.location.category isEqualToString:@"restaurant"])
            {
                [self.imgLocation setImage:[UIImage imageNamed:@"eat_type.png"]];
            }
            
            self.lbName.text = self.location.name;
            
            
            if(![self.location.city isEqual:[NSNull null]] && self.location.city != nil)
            {
                self.lbAddress.text = [NSString stringWithFormat:@"%@ \n%@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.city, [self.location.state isEqualToString:@""] ? @"" : self.location.state,  self.location.zipCode ];
                
            }
            else
            {
                self.lbAddress.text = [NSString stringWithFormat:@"%@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.state, self.location.zipCode];
                
            }
            
           
            
            if(self.location.phoneNumber)
            {
                self.lbPhone.text = [NSString stringWithFormat:@"Phone: %@", self.location.phoneNumber];

            }
            else
            {
                self.lbPhone.text = @"";
            }
            if(self.location.reccitCount > 0)
            {
                _lblReccits.hidden = NO;

                if(self.location.reccitCount == 1)
                {
                    [_lblReccits setText:[NSString stringWithFormat:@"%i reccit", self.location.reccitCount]];
                }
                else
                {
                    [_lblReccits setText:[NSString stringWithFormat:@"%i reccits", self.location.reccitCount]];
                    
                }

            }
            /*if(self.location.recommendation != nil)
            {
                if (self.location.recommendation) {
                    _imgLike.hidden = NO;
//                } else {
                    _imgLike.hidden = YES;

                }
                
            }*/
            [self.rateView setRate:self.location.rating];
            /*if (self.location.recommendation) {
                self.btnLike.selected = YES;
            } else {
                self.btnUnLike.selected = NO;
            }
            */
            CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
            MKCoordinateRegion region = {{0,0},{.001,.001}};
            region.center = currentLocation;
            
            self.mapView.delegate = self;
            
            // add annotation to map
            RCMapAnnotation *annotation = [[RCMapAnnotation alloc] init];
            annotation.myLocation = self.location;
            annotation.title = self.location.name;
            annotation.coordinate = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
            [self.mapView addAnnotation:annotation];
            
            
            /*CLLocationCoordinate2D curLoc = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate] getCurrentLocation];

            RCMapAnnotation *annotation2 = [[RCMapAnnotation alloc] init];
            annotation2.title = @"Current location";
            annotation2.coordinate = CLLocationCoordinate2DMake(curLoc.latitude, curLoc.longitude);
            [self.mapView addAnnotation:annotation2];*/
            
            //MKPointAnnotation *userLocation = [[MKPointAnnotation alloc] init];
            //userLocation.coordinate = currentLocation;
            //[self.mapView addAnnotation:userLocation];
            
            [self.mapView setRegion:region animated:NO];
            self.mapView.showsUserLocation = YES;
            
            
            [self centerMap2];
            
        } else {
            
            
            
            self.imgLocation.hidden = YES;
            self.mapView.hidden = NO;
            self.viewInfo.hidden = NO;
            
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

                    self.location.address = [[RCDataHolder getPlacemark].addressDictionary objectForKey:@"FormattedAddressLines"] == nil ? @"" : [[[RCDataHolder getPlacemark].addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@","];
                    self.location.street = [[RCDataHolder getPlacemark].addressDictionary objectForKey:@"Street"] == nil ? @"" : [[RCDataHolder getPlacemark].addressDictionary objectForKey:@"Street"];

                    self.location.zipCode = [placemark.addressDictionary objectForKey:@"ZIP"];
                    
                    
                    self.lbName.text = self.location.name;
                    if(![self.location.city isEqual:[NSNull null]] && self.location.city != nil)
                    {
                        self.lbAddress.text = [NSString stringWithFormat:@"%@ %@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.city, [self.location.state isEqualToString:@""] ? @"" : self.location.state,  self.location.zipCode ];
                        
                    }
                    else
                    {
                        self.lbAddress.text = [NSString stringWithFormat:@"%@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.state, self.location.zipCode];
                        
                    }
                    
                    if(self.location.phoneNumber)
                    {
                        self.lbPhone.text = [NSString stringWithFormat:@"Phone: %@", self.location.phoneNumber];
                        
                    }
                    else
                    {
                        self.lbPhone.text = @"";
                    }
                }
            }];
            
            MKCoordinateRegion region = {{0,0},{.001,.001}};
            region.center = CLLocationCoordinate2DMake(currentLocation.latitude, currentLocation.longitude);
            [self.mapView setRegion:region animated:NO];
            self.mapView.showsUserLocation = YES;
        }
    }
    
    
   
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id<MKAnnotation>)a
{
    
    if(![a isKindOfClass:[MKUserLocation class]])
    {
        MKAnnotationView* annotationView = nil;
        
        NSString* identifier = @"Image";
        
        //RCMapAnnotationView * imageAnnotationView = (RCMapAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:identifier];
        //if(nil == imageAnnotationView)
        //{
        RCMapAnnotationView* imageAnnotationView = [[RCMapAnnotationView alloc] initWithAnnotation:a reuseIdentifier:identifier];
        
        //}
        
        annotationView = imageAnnotationView;
        
        annotationView.canShowCallout = YES;
        //UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //MapAnnotation* csAnnotation = (MapAnnotation*)a;
        
        //detailButton.tag = csAnnotation.tag;
        //[detailButton addTarget:self action:@selector(goToPlace:) forControlEvents:UIControlEventTouchUpInside];
        //annotationView.rightCalloutAccessoryView = detailButton;
        //annotationView.calloutOffset = CGPointMake(0, 4);
        //annotationView.centerOffset =  CGPointMake(0, 0);
        return annotationView;
    }
    return nil;
    
    
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

        RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate hideConversationButton];
        
        
        self.reviewVc = [[RCReviewInDetailsViewController alloc] initWithNibName:@"RCReviewInDetailsViewController" bundle:nil];
        self.reviewVc.vsParrent = self;
        self.reviewVc.location = self.location;
        self.reviewVc.shouldSendImmediately = YES;
        //[self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
        
        [self presentSemiModalViewController:self.reviewVc];
    }
}

- (IBAction)btnWhereTouched:(id)sender
{

    if (self.location != nil)
    {
        RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate hideConversationButton];
        
        self.reviewVc = [[RCReviewInDetailsViewController alloc] initWithNibName:@"RCReviewInDetailsViewController" bundle:nil];
        self.reviewVc.vsParrent = self;
        self.reviewVc.location = self.location;
        self.reviewVc.shouldSendImmediately = NO;
        //[self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
        
        [self presentSemiModalViewController:self.reviewVc];
    }
    
    //[self Publish:@"test"];
    //[self sentToTwitter:@"test"];
    
    /*self.messageVc = [[RCWhereAmIViewController alloc] initWithNibName:@"RCWhereAmIViewController" bundle:nil];
    self.messageVc.vsParrent = self;
    self.messageVc.shouldSendImmediately = NO;
    [self.messageVc.view setBackgroundColor:[UIColor clearColor]];
    
    [self presentSemiModalViewController:self.messageVc];*/
}

- (IBAction)btnCloseTouched:(id)sender
{
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnAddFriendTouched:(id)sender
{
    
    
        RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate hideConversationButton];
    
    
    [self performSegueWithIdentifier:@"PushListFriends" sender:nil];
}

- (IBAction)swFacebookChange:(id)sender
{
    RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];

    
    if (self.swFacebook.isOn)
    {
        
       if (FBSession.activeSession.isOpen) {
           
          /* [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                                 defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                                                     NSLog(@"error %@", error.description);
                                                     if(error)
                                                     {
                                                         
                                                         dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                             [alert show];
                                                         });
                                                     }
                                                 }];
           */
           
        
           
           
            
        } else {
            //HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            //RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate openSessionWithAllowLoginUI:NO];
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

-(NSString *)parseError:(NSError *)error
{
    
    NSInteger errCode = [[[[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"] integerValue];
    switch (errCode) {
        case 506:
        case 100:
            return @"Duplicate status mesage. Please add some text to checkin.";
            break;
            
        default:
            break;
    }
    return @"Unknown error. Please try again later.";
}

- (void)Publish:(NSString *)message {
    // Show the activity indicator.
    
    // Create the parameters dictionary that will keep the data that will be posted.
    NSMutableArray *fArray = [NSMutableArray new];
    for (RCPerson *person in self.listFriends)
    {

        [fArray addObject:person.ID];
    }
    

    
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate] getCurrentLocation];
    if(FBSession.activeSession.isOpen)
    {

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
                    //NSString *coor = [NSString stringWithFormat:@"{\"latitude\":\"%f\", \"longitude\":\"%f\"}", currentLocation.latitude, currentLocation.longitude];
                    NSMutableDictionary * params = [NSMutableDictionary new];
                    
                    //NSDictionary *place = @{@"name":[res objectForKey:@"name"], @"id":[res objectForKey:@"id"]};//, @"location":[res objectForKey:@"location"] };
                    
                    //NSDictionary *place = @{@"id":[res objectForKey:@"id"]};//, @"location":[res objectForKey:@"location"] };

                    
                    if(fArray.count > 0)
                    {
                        params = [NSMutableDictionary dictionaryWithObjectsAndKeys: message, @"message",[fArray componentsJoinedByString:@","], @"tags",  [res objectForKey:@"id"], @"place", nil];
                        
                    }
                    else
                    {
                        params = [NSMutableDictionary dictionaryWithObjectsAndKeys: message, @"message", [res objectForKey:@"id"], @"place", nil];
                        
                    }
                    
                    //params = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"test", @"message", nil];

                    NSLog(@"%@", params);
                    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
                    postRequest.session = FBSession.activeSession;
                    if(![postRequest.session.permissions containsObject:@"publish_stream"])
                    {
                        
                        [postRequest.session requestNewPublishPermissions:@[@"publish_stream", @"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                            [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                NSLog(@"error %@", error.description);
                                if(error)
                                {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" message:[self parseError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                    });
                                }
                                NSLog(@"%@", result);
                                
                                //[self checkinMe];
                                
                            }];
                        }];
                    }
                    else
                    {
                        [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            NSLog(@"error %@", error.description);
                            if(error)
                            {
                                //NSLog(@"%@", [[[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"code"]);

                                
                                dispatch_async(dispatch_get_main_queue(), ^(void) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" message:[self parseError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                });
                            }
                            NSLog(@"%@", result);
                            //[self checkinMe];
                            
                        }];
                    }
                    
                }
                else
                {
                    FBRequest *postRequest = [FBRequest requestForPostStatusUpdate:message];
                    postRequest.session = FBSession.activeSession;
                    
                    
                    if(![postRequest.session.permissions containsObject:@"publish_stream"])
                    {
                        [postRequest.session requestNewPublishPermissions:@[@"publish_stream", @"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                            [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                if(error)
                                {
                                    //NSLog(@"%d", error.fberrorCategory);

                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" message:[self parseError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                    });
                                }
                                NSLog(@"%@", result);
                                //[self checkinMe];
                                
                            }];
                        }];
                    }
                    else
                    {
                        [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            if(error)
                            {
                                //NSLog(@"%d", error.fberrorCategory);

                                dispatch_async(dispatch_get_main_queue(), ^(void) {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook error" message:[self parseError:error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                });
                            }
                            NSLog(@"%@", [error description]);
                            //[self checkinMe];
                            
                        }];
                    }
                    
                    
                }
                
                
            }
            else
            {
                NSLog(@"postLocRequest err %@", [error description]);
                
                FBRequest *postRequest = [FBRequest requestForPostStatusUpdate:message];
                postRequest.session = FBSession.activeSession;
                
                
                if(![postRequest.session.permissions containsObject:@"publish_stream"])
                {
                    [postRequest.session requestNewPublishPermissions:@[@"publish_stream", @"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
                        [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            
                            NSLog(@"%@", [error description]);
                            //[self checkinMe];
                            
                        }];
                    }];
                }
                else
                {
                    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        
                        NSLog(@"%@", [error description]);
                        //[self checkinMe];
                        
                    }];
                }
                
            }
            
            
        }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Could not send checkin to Facebook. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
    }
    
    
    
   
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
        
        //[self checkinMe];
    }
    
    /*if(_engine.isAuthorized)
    {
         [_engine sendUpdate:message];
    }*/
    
    
    
   

    
}



- (IBAction)btnCheckInTouched:(id)sender
{
    

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
            [self Publish:[NSString stringWithFormat:@"%@. ", self.messageString]];
        }
        else
        {
            [self Publish:[NSString stringWithFormat:@" "]];
        }
    }

    [self checkinMe];
    
    
    
    
}

-(void)returnBack
{
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideConversationButton];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)checkinMe
{
 
   
    
    
   
    
    NSString *urlString = [NSString stringWithFormat:@"%@",kRCAPIAddPlaceDOTNET];
    
    NSLog(@"REQUEST URL: %@", urlString);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSURL *url = [NSURL URLWithString:urlString];

    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    self.location.recommendation = @"null";
    
    [client postPath:@"" parameters:@{@"review":[RCCommonUtils buildReviewString:self.location]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"responseObject %@", rO);
        
        NSInteger rplaceId = [[rO objectForKey:@"UpdateReviewResult"] integerValue];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if(rplaceId > 0)
        {
            [[RCVibeHelper sharedInstance] addUserToPlaceTalk:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] placeId:rplaceId completionBlock:^(BOOL result, NSError *error) {
                if(result)
                {
                    NSLog(@"checkinMe!");
                    
                }
                else
                {
                    NSLog(@"error in checkinMe %@", error.description);
                }
            }];
        }
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Checkin with Reccit successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
        
        RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate hideConversationButton];
        
        [self performSelector:@selector(returnBack) withObject:nil afterDelay:1.5];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sendReview error: %@", error.description);
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];

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
                    [self makeStringWithKeyAndValue:@"type" value:self.location.category],
                    [self makeStringWithKeyAndValue:@"genre" value:self.location.genre],
                    [self makeStringWithKeyAndValue:@"lat" value:[NSString stringWithFormat:@"%f",self.location.latitude]],
                    [self makeStringWithKeyAndValue:@"long" value:[NSString stringWithFormat:@"%f",self.location.longitude]],
                    [self makeStringWithKeyAndValue:@"street" value:self.location.street],
                    [self makeStringWithKeyAndValue:@"phone" value:self.location.phoneNumber],
                    [self makeStringWithKeyAndValue2:@"place_id" value:[NSString stringWithFormat:@"%i", self.location.ID > 0 ? self.location.ID : 0]],
                    nil];
    
    
    
    NSString *clock = [NSString stringWithFormat:@"json_place={%@}", [arr componentsJoinedByString:@","]];
    
    
    
    //NSLog(@"%@", [clock stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
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
        //[RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Login failed with Facebook"];
    }
}

- (void)loginFacebookSuccess
{
    [HUD hide:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    /*if ([[NSUserDefaults standardUserDefaults] objectForKey:kRCFoursquareLoggedIn] == nil)
    {
        [self performSegueWithIdentifier:@"PushFoursquare" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"PushRate" sender:nil];
    }*/
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

- (void)viewDidUnload {
    [self setLblReccits:nil];
    [self setImgLike:nil];
    [super viewDidUnload];
}
@end
