//
//  RCSearchViewController.m
//  Reccit
//
//  Created by Lee Way on 1/29/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCSearchViewController.h"
#import "RCDefine.h"
#import "RCAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "RCDataHolder.h"
#import "RCSearchResultViewController.h"
#import "RCSurpriseViewController.h"
#import "RCLocation.h"
#import "RCMapAnnotation.h"
#import "RCMapAnnotationView.h"
#define kAPIGetGenres @"http://bizannouncements.com/Vega/services/app/cuisines.php"



#define kRCAPICheckInGetLocationArround @"http://bizannouncements.com/Vega/services/app/appCheckin.php?lat=%lf&long=%lf&type=%@"

@interface RCSearchViewController ()
{
    UITextField *currentTextField;
    UITapGestureRecognizer *cancelGesture;
    
    CGRect mapRect;
}

@end

@implementation RCSearchViewController

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
    
    self.tfGenre.inputView = self.pickerView;
    self.tfPrice.inputView = self.pickerView;
    self.tfPrice.inputAccessoryView = self.toolbar;
    self.tfGenre.inputAccessoryView = self.toolbar;
    self.tfLocation.inputAccessoryView = self.toolbar;
    
    _btnReduce.hidden = YES;
    [self.view setBackgroundColor:kRCBackgroundView];
}


-(IBAction)increaseReduceMap:(id)sender
{
    if(CGRectEqualToRect(self.mapView.frame, mapRect))
    {
        self.mapView.frame = CGRectMake(0, 0, 320, [self isIphone5]  ? 508 : 420);
        _btnIncrease.hidden = YES;
        _btnReduce.hidden = NO;
    }
    else
    {
        self.mapView.frame = mapRect;
        _btnIncrease.hidden = NO;
        _btnReduce.hidden = YES;
    }
}

-(BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                //NSLog(@"iPhone 4 Resolution");
                return NO;
            }
            if(result.height == 1136) {
                //NSLog(@"iPhone 5 Resolution");
                //[[UIScreen mainScreen] bounds].size =result;
                return YES;
            }
        }
        else{
            // NSLog(@"Standard Resolution");
            return NO;
        }
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    MKCoordinateRegion region = {{0,0},{.001,.001}};
    region.center = currentLocation;
    [self.mapView setRegion:region animated:NO];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    mapRect = self.mapView.frame;

    if ([RCDataHolder getCurrentCity] != nil) {
        self.searchBar.placeholder = [NSString stringWithFormat:@"keyword/place ^ %@", [RCDataHolder getCurrentCity]];
        self.tfLocation.text = [RCDataHolder getCurrentCity];
    } else {
        [self loadCurrentCity];
    }
    
    if ([RCDataHolder getListCountry] == nil)
    {
        [self loadGerne];
    }
    
    if (![self.categoryName isEqualToString:@"restaurant"])
    {
        self.tfGenre.hidden = YES;
        self.bgGenre.hidden = YES;
        self.bgSearchGenre.hidden = YES;
    }
    
    [self callAPIGetListLocation];
}

- (void)callAPIGetListLocation
{
    
    if (![RCCommonUtils isLocationServiceOn])
    {
        [RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"You must enable Location Service on App Setting to using this function!"];
        return;
    }
    
    // Cancel old request
    if (self.request != nil && [self.request isExecuting])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.request clearDelegatesAndCancel];
    }
    

    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    NSString *urlString = [NSString stringWithFormat:kRCAPICheckInGetLocationArround, currentLocation.latitude, currentLocation.longitude, self.categoryName];
    NSLog(@"REQUEST URL: %@", urlString);
    
    // Start new request
    NSURL *url = [NSURL URLWithString:urlString];
    self.request = [ASIHTTPRequest requestWithURL:url];
    
    [self.request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
        
        [self.listLocation removeAllObjects];
        [self.mapView removeAnnotations:self.listAnnotation];
        [self.listAnnotation removeAllObjects];
        
        for (NSDictionary *category in responseObject)
        {
            for (NSDictionary *locationDic in [responseObject objectForKey:[category description]])
            {
                NSLog(@"locationDic - %@",locationDic);
                RCLocation *location = [[RCLocation alloc] init];
                location.name = [locationDic objectForKey:@"name"];
                location.type = [locationDic objectForKey:@"type"];
                location.address = [locationDic objectForKey:@"address"];
                if ([locationDic objectForKey:@"country"] != nil && [locationDic objectForKey:@"country"] != [NSNull null]) {
                    location.country  = [locationDic objectForKey:@"country"];
                    NSLog(@"%@", location.country);
                }
                if ([locationDic objectForKey:@"locality"] != nil && [locationDic objectForKey:@"locality"] != [NSNull null]) {
                    location.locality  = [locationDic objectForKey:@"locality"];
                }
                if ([locationDic objectForKey:@"tel"] != nil && [locationDic objectForKey:@"tel"] != [NSNull null]) {
                    location.phoneNumber = [locationDic objectForKey:@"tel"];
                }
                location.category = [category description];
                location.latitude = [[locationDic objectForKey:@"latitude"] doubleValue];
                location.longitude = [[locationDic objectForKey:@"longitude"] doubleValue];
                
                if ([locationDic objectForKey:@"rating"] != nil && [locationDic objectForKey:@"rating"] != [NSNull null]) {
                    location.rating = [[locationDic objectForKey:@"rating"] doubleValue];
                } else {
                    location.rating = 0;
                }
                
                [self.listLocation addObject:location];
                
                // add annotation to map
                RCMapAnnotation *annotation = [[RCMapAnnotation alloc] init];
                annotation.myLocation = location;
                annotation.title = location.name;
                annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                [self.mapView addAnnotation:annotation];
                [self.listAnnotation addObject:annotation];
                
                
                
                [self centerMap2];
            }
            
            //            [RCCommonUtils zoomToFitMapAnnotations:self.mapView annotations:self.mapView.annotations];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [self.request setFailedBlock:^{
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [self.request startAsynchronous];
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



- (void)loadGerne
{
    // Start request gerne
    NSURL *url = [NSURL URLWithString:kAPIGetGenres];
    self.cRequest = [ASIHTTPRequest requestWithURL:url];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.cRequest setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.cRequest responseData] options:kNilOptions error:nil];
        
        NSMutableArray *listCountry = [[NSMutableArray alloc] init];
        for (NSString *country in [responseObject objectForKey:@"cuisine"])
        {
            [listCountry addObject:country];
        }
        
        [RCDataHolder setListCountry:listCountry];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [self.cRequest setFailedBlock:^{
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [self.cRequest startAsynchronous];
}

- (void)loadCurrentCity
{
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil) {

//            [RCDataHolder setCurrentCity:[NSString stringWithFormat:@"%@,%@", [[placemarks objectAtIndex:0] locality], [[placemarks objectAtIndex:0] country]]];
            
            [RCDataHolder setCurrentCity:[[placemarks objectAtIndex:0] locality]];
            self.searchBar.placeholder = [NSString stringWithFormat:@"keyword/place ^ %@", [RCDataHolder getCurrentCity]];
            self.tfLocation.text = [RCDataHolder getCurrentCity];
        } else {
            [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
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
    if (sender == self.btnGo)
    {
        RCSearchResultViewController *result = (RCSearchResultViewController *)segue.destinationViewController;
        
        NSString *query = [NSString stringWithFormat:@"city=%@&type=%@&dist=%d", self.tfLocation.text, self.categoryName, (int)self.sliderDistance.value];
        
        result.isSurprase = NO;
        result.showTabs = YES;
        if ([self.searchBar.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&search=%@", query, self.searchBar.text];
        }
        if ([self.tfGenre.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&cuisine=%@", query, self.tfGenre.text];
        }
        
        if ([self.tfPrice.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&price=%d", query, [self.tfPrice.text length]];
        }
        result.querySearch = query;
    }
    
    if (sender == self.btnSuprise)
    {
        RCSearchResultViewController *result = (RCSearchResultViewController *)segue.destinationViewController;
        
        NSString *query = [NSString stringWithFormat:@"filter=surpriseme&city=%@&type=%@&dist=%d", self.tfLocation.text , self.categoryName, (int)self.sliderDistance.value];
        
        result.isSurprase = YES;
        result.showTabs = NO;
        if ([self.searchBar.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&search=%@", query, self.searchBar.text];
        }
        if ([self.tfGenre.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&cuisine=%@", query, self.tfGenre.text];
        }
        
        if ([self.tfPrice.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&price=%d", query, [self.tfPrice.text length]];
        }
        result.querySearch = query;
    }
    
    if (sender == self.btnSearch)
    {
        RCSearchResultViewController *result = (RCSearchResultViewController *)segue.destinationViewController;
        
        NSString *query = [NSString stringWithFormat:@"city=%@&type=%@", self.tfLocation.text, self.categoryName];
        result.isSurprase = NO;
        result.showTabs = NO;
        if ([self.searchBar.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&search=%@", query, self.searchBar.text];
        }
        result.querySearch = query;
        result.searchString = self.searchBar.text;
    }
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnBackTouched:(id)sender
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }
                     completion:^(BOOL finished){
                         [self.navigationController popViewControllerAnimated:NO];
                     }];
}

- (IBAction)btnSupriseMeTouched:(id)sender
{
    
    
    
    [self performSegueWithIdentifier:@"PushResultSearch" sender:sender];
}

- (IBAction)btnGoTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushResultSearch" sender:sender];
}

- (IBAction)btnDoneTouched:(id)sender
{
    [self.tfGenre resignFirstResponder];
    [self.tfLocation resignFirstResponder];
    [self.tfPrice resignFirstResponder];
}

- (IBAction)btnSeachTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushResultSearch" sender:sender];
}

#pragma mark -
#pragma mark - TextField delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    cancelGesture = [UITapGestureRecognizer new];
    [cancelGesture addTarget:self action:@selector(backgroundTouched:)];
    [self.view addGestureRecognizer:cancelGesture];
    
    currentTextField = textField;
    
    if (textField.tag == 1000) return;
    
    [self.pickerView reloadAllComponents];
    
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        CGRect frame = self.view.frame;
        frame.origin.y = -150;
        self.view.frame = frame;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (cancelGesture) {
        [self.view removeGestureRecognizer:cancelGesture];;
        cancelGesture = nil;
    }
    
    currentTextField = nil;
    
    if (textField.tag == 1000) return;
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
}

-(void) backgroundTouched:(id) sender {
    [currentTextField resignFirstResponder];
}

#pragma mark -
#pragma mark - Picker delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (currentTextField == self.tfGenre)
    {
        if (row == 0) return @"";
        return [[RCDataHolder getListCountry] objectAtIndex:row-1];
    }
    
    if (currentTextField == self.tfPrice)
    {
        switch (row) {
            case 0:
                return @"";
            case 1:
                return @"$";
            case 2:
                return @"$$";
            case 3:
                return @"$$$";
            case 4:
                return @"$$$$";
            case 5:
                return @"$$$$$";
        }
    }
    
    return nil;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (currentTextField == self.tfGenre)
    {
        return [[RCDataHolder getListCountry] count] + 1;
    }
    
    if (currentTextField == self.tfPrice)
    {
        return 6;
    }
    
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (currentTextField == self.tfGenre)
    {
        if (row == 0)
            self.tfGenre.text = @"";
        else
            self.tfGenre.text = [[RCDataHolder getListCountry] objectAtIndex:row-1];
    }
    
    if (currentTextField == self.tfPrice)
    {
        switch (row) {
            case 0:
                self.tfPrice.text = @"";
                break;
            case 1:
                self.tfPrice.text = @"$";
                break;
            case 2:
                self.tfPrice.text = @"$$";
                break;
            case 3:
                self.tfPrice.text = @"$$$";
                break;
            case 4:
                self.tfPrice.text = @"$$$$";
                break;
            case 5:
                self.tfPrice.text = @"$$$$$";
                break;
        }
    }
}

- (void)viewDidUnload {
    [self setBtnIncrease:nil];
    [self setBtnReduce:nil];
    [super viewDidUnload];
}
@end
