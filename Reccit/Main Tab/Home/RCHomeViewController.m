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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.tfSearch setPlaceholder:[NSString stringWithFormat:@"Search for keyword/place ^ %@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCCurrentCity]]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    if ([RCDataHolder getCurrentCity] == nil) {
        [self loadCurrentCity];
    }
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)loadCurrentCity
{
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil) {
            //            [RCDataHolder setCurrentCity:[NSString stringWithFormat:@"%@,%@", [[placemarks objectAtIndex:0] locality], [[placemarks objectAtIndex:0] country]]];
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"%@", placemark.addressDictionary);
        
            [RCDataHolder setCurrentCity:[[placemarks objectAtIndex:0] locality]];
            //self.location.address = ABCreateStringWithAddressDictionary([[placemarks objectAtIndex:0] addressDictionary], NO);
            

        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

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
        
        surpsrice.querySearch = [NSString stringWithFormat:@"user=%@&type=happyhours&city=%@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [RCDataHolder getCurrentCity]];
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
