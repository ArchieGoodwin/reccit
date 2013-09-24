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
#import "AFNetworking.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "TRAutocompleteView.h"
#import "TRGoogleMapsAutocompleteItemsSource.h"
#import "TRTextFieldExtensions.h"
#import "TRGoogleMapsAutocompletionCellFactory.h"
#import "RCLocationDetailViewController.h"
#define kAPIGetGenres @"http://bizannouncements.com/Vega/services/app/cuisines.php"


#define kRCAPICheckInGetLocationArround @"http://bizannouncements.com/Vega/services/app/appCheckin.php?lat=%lf&long=%lf&type=%@"
#define kRCAPICheckInGetLocationArroundDOTNET  @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/GetFactual?userfbid=%@&city=%@&type=%@&latitude=%f&longitude=%f"

@interface RCSearchViewController ()
{
    UITextField *currentTextField;
    UITapGestureRecognizer *cancelGesture;
    CGRect viewRect;
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

-(BOOL)prefersStatusBarHidden
{
    return YES;
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
    mapRect = self.mapView.frame;

    self.listLocation = [NSMutableArray new];
    self.listAnnotation = [NSMutableArray new];
    if([RCCommonUtils isIphone5])
    {
        CGRect frame = _viewPrice.frame;
        frame.origin.y = 90;
        _viewPrice.frame = frame;
        
        frame = _viewGenre.frame;
        frame.origin.y = 158;
        _viewGenre.frame = frame;
        
    }

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        CGRect rect =  self.btnGo.frame;
        rect.origin.y = rect.origin.y - 30;
        self.btnGo.frame = rect;
        
        rect = self.viewContent.frame;
        rect.origin.y = rect.origin.y + 20;
        rect.size.height = rect.size.height  -20;
        self.viewContent.frame = rect;
        
        rect  = self.mapView.frame;
        rect.size.height = rect.size.height + 20;
        mapRect = rect;
        self.mapView.frame = rect;
    }
    

    
    _autocompleteView = [TRAutocompleteView autocompleteViewBindedTo:autoTextField
                                                         usingSource:[[TRGoogleMapsAutocompleteItemsSource alloc] initWithMinimumCharactersToTrigger:2 apiKey:@"AIzaSyDReGYWBPSVAmKXki80akGombUHBDwWp48"]
                                                         cellFactory:[[TRGoogleMapsAutocompletionCellFactory alloc] initWithCellForegroundColor:[UIColor lightGrayColor] fontSize:14]
                                                        presentingIn:self];
    
    autoTextField.delegate = _autocompleteView;
    //autoTextField.delegate = self;
    
    
    /*for (UIView * v in self.searchDispController.searchBar.subviews) {
        if ([v isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            v.superview.alpha = 0;
            UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(47, 185, 250, 40)];
            containerView.tag = 9009;
            [containerView addSubview:v];
            [self.view addSubview:containerView];
        }
    }

    self.searchDispController.searchBar.showsCancelButton = YES;
    self.searchDispController.searchBar.showsScopeBar = YES;
    [self.searchDispController.searchBar sizeToFit];
    self.searchDispController.searchBar.frame = CGRectMake(47, 15, 250, 40);*/

    
	// Do any additional setup after loading the view.
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    self.tfGenre.inputView = self.pickerView;
    self.tfPrice.inputView = self.pickerView;
    self.tfPrice.inputAccessoryView = self.toolbar;
    self.tfGenre.inputAccessoryView = self.toolbar;
    self.tfLocation.inputAccessoryView = self.toolbar;
    self.searchBarTxt.returnKeyType = UIReturnKeySearch;
    _btnReduce.hidden = YES;
    [self.view setBackgroundColor:kRCBackgroundView];
    
    
}


-(IBAction)increaseReduceMap:(id)sender
{
    if(CGRectEqualToRect(self.mapView.frame, mapRect))
    {
        self.mapView.frame = CGRectMake(0, 0, 320, [RCCommonUtils isIphone5]  ? (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?  518 : 508) : (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ?  430 : 420));
        _btnIncrease.hidden = YES;
        _btnReduce.hidden = NO;
        
        autoTextField.hidden = YES;
        

    }
    else
    {
        self.mapView.frame = mapRect;
        _btnIncrease.hidden = NO;
        _btnReduce.hidden = YES;
        autoTextField.hidden = NO;
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    [self.navigationController setNavigationBarHidden:YES];
    
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    MKCoordinateRegion region = {{0,0},{.003,.003}};
    region.center = currentLocation;
    [self.mapView setRegion:region animated:NO];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;

    if ([RCDataHolder getCurrentCity] != nil) {
        self.searchBarTxt.placeholder = [NSString stringWithFormat:@"keyword/place"];
        //self.searchDispController.searchBar.text = [RCDataHolder getCurrentCity];
        autoTextField.text = [RCDataHolder getCurrentCity];

    } else {
        [self loadCurrentCity];

    }
    
    //[self.searchDispController.searchBar resignFirstResponder];
    //[self.searchDispController setActive:NO];
    //self.searchDispController.searchResultsTableView.alpha = 0.0;

    
    if ([self.categoryName isEqualToString:@"restaurant"])
    {
        [self loadGerne];
    }
    
    if (![self.categoryName isEqualToString:@"restaurant"])
    {
        self.tfGenre.hidden = YES;
        self.bgGenre.hidden = YES;
        self.bgSearchGenre.hidden = YES;
    }
   // self.searchDispController.searchBar.frame = CGRectMake(self.searchDispController.searchBar.frame.origin.x, self.searchDispController.searchBar.frame.origin.y, 200, 40);
    [self callAPIGetListLocation];
    
    [autoTextField resignFirstResponder];
    [self.searchBarTxt resignFirstResponder];
}

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    // Put anything that starts with this substring into the autoCompleteArray
    // The items in this array is what will show up in the table view
    
   
    if(![substring isEqualToString:@""])
    {
        SPGooglePlacesAutocompleteQuery *query = [SPGooglePlacesAutocompleteQuery query];
        query.input = substring;
        query.radius = 100.0;
        query.language = @"en";
        
        [query fetchPlaces:^(NSArray *places, NSError *error) {
            if (error) {
                SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
            } else {
                searchResultPlaces = places;
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        }];
    }
    
    
}


/*-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}*/

- (void)callAPIGetListLocation
{
    
    if (![RCCommonUtils isLocationServiceOn])
    {
        [RCCommonUtils showMessageWithTitle:@"Warning" andContent:@"You must enable Location Service on iOS Settings to using this function!"];
        return;
    }


   // CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    
    CLLocationDegrees longitude1 = self.mapView.region.center.longitude;
    CLLocationDegrees latitude1 = self.mapView.region.center.latitude;
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:latitude1 longitude:longitude1];
    
    
    
    NSString *urlString = [NSString stringWithFormat:kRCAPICheckInGetLocationArroundDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], [[RCDataHolder getCurrentCity] stringByReplacingOccurrencesOfString:@" " withString:@"%20"], self.categoryName, otherLocation.coordinate.latitude, otherLocation.coordinate.longitude];
    NSLog(@"REQUEST URL home: %@", urlString);
    
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
            int i = 0;
            for (NSDictionary *locationDic in [rO objectForKey:[category description]])
            {
                NSLog(@"%@",locationDic);
                RCLocation *location = [RCCommonUtils getLocationFromDictionary:locationDic];
                location.ID = i;
                i++;
                if(location)
                {
                    [self.listLocation addObject:location];
                    
                    // add annotation to map
                    RCMapAnnotation *annotation = [[RCMapAnnotation alloc] init];
                    annotation.myLocation = location;
                    annotation.title = location.name;
                    annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
                    [self.mapView addAnnotation:annotation];
                    [self.listAnnotation addObject:annotation];
                    
                }
                
                
                /*NSLog(@"locationDic - %@",locationDic);
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
                }*/
                
                
                
                
                
                //[self centerMap2];
            }
            
            //            [RCCommonUtils zoomToFitMapAnnotations:self.mapView annotations:self.mapView.annotations];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [operation start];
    

    
}

-(RCLocation *)getLocationById:(NSInteger)locId
{
    /*for(RCLocation *loc in self.listLocation)
    {
        if(loc.ID == locId)
        {
            return loc;
        }
    }
    return nil;*/
    return [self.listLocation objectAtIndex:locId];
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
    if([a isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
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
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        detailButton.tag = annotationView.tag;
        [detailButton addTarget:self action:@selector(goToPlace:) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = detailButton;
        annotationView.calloutOffset = CGPointMake(0, 4);
        annotationView.centerOffset =  CGPointMake(0, 0);
        return annotationView;
    }
    return nil;
    
   
}


-(void)mapView:(MKMapView *)mapView1 regionDidChangeAnimated:(BOOL)animated
{

    
   

    [self callAPIGetListLocation];
    
    
    
}


-(IBAction)goToPlace:(id)sender
{
    UIButton *btn = (UIButton *)sender;

    int locId = btn.tag;
    RCLocation *loc = [self getLocationById:locId];
    
    
    [self performSegueWithIdentifier:@"showLocDetails" sender:loc];

}



- (void)loadGerne
{
    // Start request gerne
    NSURL *url = [NSURL URLWithString:kAPIGetGenres];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        NSMutableArray *listCountry = [[NSMutableArray alloc] init];
        for (NSString *country in [rO objectForKey:@"cuisine"])
        {
            [listCountry addObject:country];
        }
        
        [RCDataHolder setListCountry:listCountry];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    

   
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
            self.searchBarTxt.placeholder = [NSString stringWithFormat:@"keyword/place ^ %@", [RCDataHolder getCurrentCity]];
            autoTextField.text = [RCDataHolder getCurrentCity];
            //self.searchDispController.searchBar.text = [RCDataHolder getCurrentCity];
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
        
        //city={city}&type={type}&genre={genre}&state={state}&country={country}&latitude={latitude}&longitude={longitude}&price={price}
        RCSearchResultViewController *result = (RCSearchResultViewController *)segue.destinationViewController;
        result.category = self.categoryName;
        NSString *query = [NSString stringWithFormat:@"city=%@&type=%@", autoTextField.text, self.categoryName];
        
        result.isSurprase = NO;
        result.showTabs = YES;
        /*if ([self.searchBar.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&search=%@", query, self.searchBar.text];
        }*/
        if ([self.tfGenre.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&genre=%@", query, self.tfGenre.text];
        }
        
        if ([self.tfPrice.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&price=%d", query, [self.tfPrice.text length]];
        }
        
        CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
        query = [NSString stringWithFormat:@"%@&latitude=%f&longitude=%f", query, currentLocation.latitude, currentLocation.longitude];
        
        result.isSearch = NO;
        result.tfLocation = autoTextField.text;
        result.categoryName = self.categoryName;
        result.querySearch = query;
    }
    
    if (sender == self.btnSuprise)
    {
        RCSearchResultViewController *result = (RCSearchResultViewController *)segue.destinationViewController;
        result.category = self.categoryName;

        NSString *query = [NSString stringWithFormat:@"filter=surpriseme&city=%@&type=%@", self.searchDispController.searchBar.text , self.categoryName];
        
        result.isSurprase = YES;
        result.showTabs = NO;
        result.tfLocation = autoTextField.text;
        result.categoryName = self.categoryName;
        if ([self.searchBarTxt.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&search=%@", query, self.searchBarTxt.text];
        }
        if ([self.tfGenre.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&genre=%@", query, self.tfGenre.text];
        }
        
        if ([self.tfPrice.text length] > 0)
        {
            query = [NSString stringWithFormat:@"%@&price=%d", query, [self.tfPrice.text length]];
        }
        result.isSearch = NO;

        result.querySearch = query;
    }
    
    if (sender == self.btnSearch)
    {
        
            RCSearchResultViewController *result = (RCSearchResultViewController *)segue.destinationViewController;
            result.category = self.categoryName;
            
            NSString *query = [NSString stringWithFormat:@"city=%@&type=%@", autoTextField.text, self.categoryName];
            result.isSurprase = NO;
            result.showTabs = NO;
            result.tfLocation = autoTextField.text;
            result.categoryName = self.categoryName;
            
            query = [NSString stringWithFormat:@"%@&searchstring=%@", query, self.searchBarTxt.text];
            result.isSearch = YES;
            result.querySearch = query;
            result.searchString = self.searchBarTxt.text;
        
       
    }
    
    if(sender != self.btnSearch && sender != self.btnSuprise && sender != self.btnGo)
    {
        
        if([segue.identifier isEqualToString:@"showLocDetails"])
        {
            
           
            
            RCLocationDetailViewController *detail = (RCLocationDetailViewController *)segue.destinationViewController;
            
            detail.location = sender;
        }
    
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
    if(self.searchBarTxt.text.length > 0)
    {
        [self performSegueWithIdentifier:@"PushResultSearch" sender:sender];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Enter keyword or name in search field please" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
 

        if(self.searchBarTxt.text.length > 0)
        {
            [self performSegueWithIdentifier:@"PushResultSearch" sender:self.btnSearch];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Enter keyword in search field please" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    
    
    

    return YES;
}

#pragma mark -
#pragma mark - TextField delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideConversationButton];
    [appDelegate hideAlert];
    
    
    
    cancelGesture = [UITapGestureRecognizer new];
    [cancelGesture addTarget:self action:@selector(backgroundTouched:)];
    [self.view addGestureRecognizer:cancelGesture];
    
    currentTextField = textField;
    
    if (textField.tag == 1000) return;
    
    /*if (textField.tag == 9010)
    {
        
        textField.frame = CGRectMake(textField.frame.origin.x, 70, textField.frame.size.width, textField.frame.size.height);
        
        return;
    }*/
    //self.pickerView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    [self.pickerView reloadAllComponents];
    
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        CGRect frame = self.view.frame;
        frame.origin.y = -150;
        self.view.frame = frame;
    }];
}


-(void)shiftView
{
    [UIView animateWithDuration:0.4 animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        CGRect frame = self.view.frame;
        frame.origin.y = -150;
        self.view.frame = frame;
    }];
}

-(void)shiftViewBack
{
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showButtonForMessages];

    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
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
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showButtonForMessages];
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

    //[appDelegate hideAlert];
    
    
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
    [self setViewCity:nil];
    [self setViewPrice:nil];
    [self setViewGenre:nil];
    [super viewDidUnload];
}







@end
