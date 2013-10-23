//
//  RCDirectViewController.m
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCDirectViewController.h"
#import "RCDefine.h"
#import "RCDataHolder.h"
#import "RCCommonUtils.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "RCAppDelegate.h"
#import "AFNetworking.h"
#define kAPIGetDirection @"http://bizannouncements.com/Vega/services/app/getDirections.php?origlat=%lf&origlong=%lf&destlat=%lf&destlong=%lf"

@interface RCDirectViewController ()
{
    NSMutableArray *arrRouteWalk;
}

@end

@implementation RCDirectViewController

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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
        //}];
        
    }
    
	// Do any additional setup after loading the view.
    _mode = 1;
    _instructions = [NSMutableArray new];
    _table.delegate = self;
    _table.dataSource = self;
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
        
    arrRouteWalk = [[NSMutableArray alloc] init];
    
    self.mainMap = [[MapView alloc] initWithFrame:
                self.mapView.frame];
	
	[self.view addSubview:self.mainMap];
    
    //[self showMap];
    [self performSelector:@selector(callAPIGetDirection:) withObject:@"driving" afterDelay:0.2];
}

- (void)showMap
{
	Place* home = [[Place alloc] init];
	home.name = @"Home";
	home.description = @"Sweet home";
	home.latitude = 43.66361000000001;
	home.longitude = -79.35547000000001;
	
	Place* office = [[Place alloc] init];
	office.name = @"Office";
	office.description = @"Bad office";
	office.latitude = 43.66361000000001;
	office.longitude = -79.35547000000001;

    NSMutableArray *routes = [[NSMutableArray alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:43.65331 longitude:-79.38277000000001];
    [routes addObject:loc];
    
	loc = [[CLLocation alloc] initWithLatitude:43.65331 longitude:-79.38277000000001];
    [routes addObject:loc];
    
    loc = [[CLLocation alloc] initWithLatitude:43.65572 longitude:-79.38373];
    [routes addObject:loc];
    
    loc = [[CLLocation alloc] initWithLatitude:43.66181 longitude:-79.35451];
    [routes addObject:loc];
    
    loc = [[CLLocation alloc] initWithLatitude:43.66361000000001 longitude:-79.35547000000001];
    [routes addObject:loc];
    
    self.mainMap.routes = routes;

    [self.mainMap showRouteTo:office];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.lbName.text = self.location.name;
    self.lbStart.text = @"Current location";
    self.lbEnd.text = self.location.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Webservice

- (void)callAPIGetDirection:(NSString *)mode
{
    // Start new request
    CLLocationCoordinate2D currentLocation = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate]getCurrentLocation];
    
   // NSString *urlString = [NSString stringWithFormat:kAPIGetDirection, currentLocation.latitude, currentLocation.longitude, self.location.latitude, self.location.longitude];
    
    //urlString = @"http://bizannouncements.com/Vega/services/app/getDirections.php?origlat=43.653310&origlong=-79.38277000000001&destlat=43.66361000000001&destlong=-79.35547000000001";
     NSString *urlString = @"";
    if(![mode isEqualToString:@"transit"])
    {
        urlString =[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=%@", currentLocation.latitude, currentLocation.longitude, self.location.latitude, self.location.longitude, mode];
    }
    else
    {
        urlString =[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=%@&departure_time=%ld", currentLocation.latitude, currentLocation.longitude, self.location.latitude, self.location.longitude, mode, (long)[[NSDate date] timeIntervalSince1970] + 1800];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@", rO);
        if(![[rO objectForKey:@"status"] isEqualToString:@"INVALID_REQUEST"] && ![[rO objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"])
        {
            
            
            //OVER_QUERY_LIMIT
            
            if(![[rO objectForKey:@"status"] isEqualToString:@"OVER_QUERY_LIMIT"])
            {
                NSArray *routes = [rO objectForKey:@"routes"];
                
                
                NSArray *legs = [routes[0] objectForKey:@"legs"];
                //NSLog(@"legs %@", legs[0]);
                NSArray *steps = [legs[0] objectForKey:@"steps"];
                //NSLog(@"steps : %@", steps);
                
                Place* office = [[Place alloc] init];
                office.name = self.location.name;
                office.description = @"";
                office.latitude = [[[legs[0] objectForKey:@"end_location"] objectForKey:@"lat"] doubleValue];
                office.longitude = [[[legs[0] objectForKey:@"end_location"] objectForKey:@"lng"] doubleValue];
                
                //NSLog(@"office: %f", office.latitude);
                
                NSMutableArray *routing = [[NSMutableArray alloc] init];
                
                [_instructions removeAllObjects];
                int ii = 1;
                for(NSDictionary *step in steps)
                {
                    [_instructions addObject:[NSString stringWithFormat:@"%i: %@", ii, [step objectForKey:@"html_instructions"]]];
                    NSDictionary *suStep = [step objectForKey:@"end_location"];
                    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[[suStep objectForKey:@"lat"] doubleValue] longitude:[[suStep objectForKey:@"lng"] doubleValue]];
                    [routing addObject:loc];
                    ii++;
                    
                }
                [_table reloadData];
                
                //self.mainMap.routes = routing;
                
                //[self.mainMap showRouteTo:office];
            }
            else
            {
                [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Directions service is down. Please try again a bit later!"];
                
            }
            
        }
        else
        {
            [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"There are no directions available!"];
            
        }
        
        
        
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
   
}


-(IBAction)showMapApp:(id)sender
{
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.location.latitude,self.location.longitude);
    
    //create MKMapItem out of coordinates
    MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
    if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        //using iOS6 native maps app
        if(_mode == 1)
        {
            [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking}];

        }
        if(_mode == 2)
        {
            [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
            
        }
        if(_mode == 3)
        {
            [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
            
        }
        
    } else{
        
        //using iOS 5 which has the Google Maps application
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f", self.location.latitude, self.location.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnBackTouched:(id)sender
{
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnTabTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    switch (btn.tag) {
        case 1001:
            [self callAPIGetDirection:@"driving"];
            _mode = 1;
            break;
        case 1002:
            [self callAPIGetDirection:@"walking"];
            _mode = 2;
            break;
        case 1003:
            [self callAPIGetDirection:@"transit"];
            _mode = 3;
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark - TableView Datasource

-(CGFloat)getLabelSize:(NSString *)text fontSize:(NSInteger)fontSize
{
    UIFont *cellFont = [UIFont systemFontOfSize:fontSize];
	CGSize constraintSize = CGSizeMake(300, MAXFLOAT);
	CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *inst = [_instructions objectAtIndex:indexPath.row];
    
        
    return [self getLabelSize:[self stringByStrippingHTML:inst] fontSize:16] + 13;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _instructions.count;
}


-(NSString *) stringByStrippingHTML:(NSString *)str {
    NSRange r;
    while ((r = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        str = [str stringByReplacingCharactersInRange:r withString:@""];
    return str;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstCell"];
    
    for(UIView *inside in cell.contentView.subviews)
    {
        [inside removeFromSuperview];
    }
    
    NSString *inst = [_instructions objectAtIndex:indexPath.row];
    
    
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectZero];
    lblText.text = [self stringByStrippingHTML:inst];
    lblText.numberOfLines = 0;
    lblText.textColor = [UIColor darkTextColor];
    lblText.lineBreakMode = NSLineBreakByWordWrapping;
    
    lblText.frame = CGRectMake(10, 5, 300, [self getLabelSize:[self stringByStrippingHTML:inst] fontSize:16]);
    
    
    [cell.contentView addSubview:lblText];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)viewDidUnload {
    [self setTable:nil];
    [super viewDidUnload];
}
@end
