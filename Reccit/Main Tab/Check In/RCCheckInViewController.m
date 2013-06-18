//
//  RCCheckInViewController.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCCheckInViewController.h"
#import "RCAppDelegate.h"
#import "MBProgressHUD.h"
#import "RCLocation.h"
#import "RCCommonUtils.h"
#import "RCDefine.h"
#import "UIImageView+WebCache.h"
#import "RCAddPlaceViewController.h"
#import "RCMapAnnotationView.h"
#import "RCMapAnnotation.h"
#import "AFNetworking.h"
#define kRCAPICheckInGetLocationArround @"http://bizannouncements.com/Vega/services/app/appCheckin.php?lat=%lf&long=%lf"

@interface RCCheckInViewController ()
{
    BOOL isFirstTime;
}

@end

@implementation RCCheckInViewController

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
    
    self.listLocation = [[NSMutableArray alloc] init];
    self.listAnnotation = [[NSMutableArray alloc] init];
    
    self.mapView.delegate = self;
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.tbLocation setSeparatorColor:[UIColor clearColor]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self callAPIGetListLocation];
    
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    MKCoordinateRegion region = {{0,0},{.001,.001}};
    region.center = currentLocation;
    [self.mapView setRegion:region animated:NO];
    self.mapView.showsUserLocation = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushAddPlace"])
    {
        RCAddPlaceViewController *addPlace = (RCAddPlaceViewController *)segue.destinationViewController;
        
        if ([sender class] == [RCLocation class]) {
            addPlace.location = sender;
            addPlace.isAddNew = NO;
        } else {
            addPlace.isAddNew = YES;
            addPlace.locationName = sender;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Webservice

- (void)callAPIGetListLocation
{
    
    if (![RCCommonUtils isLocationServiceOn])
    {
        [RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"You must enable Location Service on App Setting to using this function!"];
        return;
    }
    
    
    
    if ([self.listLocation count] == 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.tbLocation.hidden = YES;
    }
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    NSString *urlString = [NSString stringWithFormat:kRCAPICheckInGetLocationArround, currentLocation.latitude, currentLocation.longitude];
    NSLog(@"REQUEST URL callAPIGetListLocation: %@", urlString);
    
    // Start new request
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        [self.listLocation removeAllObjects];
        [self.mapView removeAnnotations:self.listAnnotation];
        [self.listAnnotation removeAllObjects];
        
        for (NSDictionary *category in rO)
        {
            for (NSDictionary *locationDic in [rO objectForKey:[category description]])
            {
                //NSLog(@"%@", locationDic);
                
                RCLocation *location = [RCCommonUtils getLocationFromDictionary:locationDic];

                
                
                
                
                /*RCLocation *location = [[RCLocation alloc] init];
                if ([locationDic objectForKey:@"place_id"] != nil && [locationDic objectForKey:@"place_id"] != [NSNull null]) {
                    location.ID = [[locationDic objectForKey:@"place_id"] integerValue];
                    
                }
                else
                {
                    location.ID = 0;
                }
                location.name = [locationDic objectForKey:@"name"];
                location.city = [locationDic objectForKey:@"city"];
                location.state = [locationDic objectForKey:@"state"];
                
                location.address = [locationDic objectForKey:@"address"];
                if ([locationDic objectForKey:@"country"] != nil && [locationDic objectForKey:@"country"] != [NSNull null]) {
                    location.country  = [locationDic objectForKey:@"country"];
                    //NSLog(@"%@", location.country);
                }
                if ([locationDic objectForKey:@"locality"] != nil && [locationDic objectForKey:@"locality"] != [NSNull null]) {
                    location.locality  = [locationDic objectForKey:@"locality"];
                }
                if ([locationDic objectForKey:@"tel"] != nil && [locationDic objectForKey:@"tel"] != [NSNull null]) {
                    location.phoneNumber = [locationDic objectForKey:@"tel"];
                }
                location.category = [locationDic objectForKey:@"type"];
                location.latitude = [[locationDic objectForKey:@"latitude"] doubleValue];
                location.longitude = [[locationDic objectForKey:@"longitude"] doubleValue];
                
                if ([locationDic objectForKey:@"rating"] != nil && [locationDic objectForKey:@"rating"] != [NSNull null]) {
                    location.rating = [[locationDic objectForKey:@"rating"] doubleValue];
                } else {
                    location.rating = 0;
                }*/
                
                [self.listLocation addObject:location];
                
                // add annotation to map
                RCMapAnnotation *annotation = [[RCMapAnnotation alloc] init];
                annotation.myLocation = location;
                annotation.title = location.name;
                annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                [self.mapView addAnnotation:annotation];
                [self.listAnnotation addObject:annotation];
            }
            
            //            [RCCommonUtils zoomToFitMapAnnotations:self.mapView annotations:self.mapView.annotations];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tbLocation reloadData];
        self.tbLocation.hidden = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
    
}

#pragma mark -
#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listLocation count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    [(UILabel *)[cell viewWithTag:1001] setTextColor:kRCPrefixTextCellColorHighLight];
    
    if (indexPath.row == [self.listLocation count]) {
        [(UILabel *)[cell viewWithTag:1000] setTextColor:kRCCheckInAddCellColorHighLight];
        [(UILabel *)[cell viewWithTag:1000] setText:@"add a place"];
        [(UILabel *)[cell viewWithTag:1001] setText:@"+"];
    } else {
        RCLocation *location = [self.listLocation objectAtIndex:indexPath.row];
        [(UILabel *)[cell viewWithTag:1000] setText:location.name];
        [(UILabel *)[cell viewWithTag:1001] setText:[NSString stringWithFormat:@"%d.", (indexPath.row + 1)]];
        [(UILabel *)[cell viewWithTag:1000] setTextColor:kRCTextCellColorHighLight];
    }
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    
    return cell;
}

#pragma mark -
#pragma mark - TableView Delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.listLocation count])
    {
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Enter the place name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
        [alertView show];
    } else {
        // Do here
        RCLocation *location = [self.listLocation objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"PushAddPlace" sender:location];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self performSegueWithIdentifier:@"PushAddPlace" sender:[alertView textFieldAtIndex:0].text];
    } else {
        
    }
}

#pragma mark - MKMapView delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // if current location
    if (annotation == mapView.userLocation) {
        return nil;
	}
    
    static NSString *identyfiy = @"ITMapAnnotationView";
    
    RCMapAnnotationView *annotationView = (RCMapAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identyfiy];
	if(annotationView == nil)
	{
		annotationView = [[RCMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identyfiy];
	}
    
    annotationView.annotation = annotation;
    [annotationView refreshImage];
    //tapping the pin produces a gray box which shows title and subtitle
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

@end
