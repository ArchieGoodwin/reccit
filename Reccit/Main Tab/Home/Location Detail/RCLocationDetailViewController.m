//
//  RCLocationDetailViewController.m
//  Reccit
//
//  Created by Lee Way on 1/31/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCLocationDetailViewController.h"
#import "RCDefine.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "RCCommonUtils.h"
#import "RCReview.h"
#import "RCWebViewController.h"
#import "RCReviewInDetailsViewController.h"
#import "RCDirectViewController.h"
#import "AFNetworking.h"
#import "VibeViewController.h"
#import "RCVibeHelper.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "RCMapAnnotationView.h"
#import "RCMapAnnotation.h"
#define kAPIGetComment @"http://bizannouncements.com/Vega/data/places/comments.php?place_id=%d&user_id=%@"

@interface RCLocationDetailViewController ()

@end

@implementation RCLocationDetailViewController

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
    
    self.mapView.delegate = self;

    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    [self performSelector:@selector(callAPIGetListReview) withObject:nil afterDelay:0.2];
}

- (IBAction)btnVibeTap:(id)sender {
    VibeViewController *controller = [[VibeViewController alloc] initWithNibName:@"VibeViewController" bundle:nil];
    controller.location = self.location;
    RCConversation *conv = [[RCVibeHelper sharedInstance] getConverationById:self.location.ID];;
    if(conv.placeName == nil)
    {
        conv.placeName = self.location.name;
        [RCConversation saveDefaultContext];
    }
    controller.convsersation = conv;
    
    [self presentViewController:controller animated:YES completion:^{
       
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
    {
        if(self.location.ID > 0)
        {
            _btnVibe.hidden = NO;

        }
    }
    else
    {
        _btnVibe.hidden = YES;
    }
    self.lbName.text = self.location.name;
    if(self.location.city != [NSNull null] && self.location.city != nil)
    {
        self.lbAddress.text = [NSString stringWithFormat:@"%@ %@", self.location.city, self.location.street];

    }
    else
    {
        self.lbAddress.text = self.location.street;

    }
    
    self.rateView.rate = self.location.rating;
    if(self.location.genre != [NSNull null] && self.location.genre != nil)
    {
        self.lbCity.text = self.location.genre;

    }
    
    /*if (self.location.phoneNumber == nil)
    {
        self.btnCall.hidden = YES;
    }*/
    
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
    MKCoordinateRegion region = {{0,0},{.001,.001}};
    region.center = currentLocation;
    
    NSLog(@"%@  %@  %f, %f", self.location.type, self.location.category, self.location.latitude, self.location.longitude);
    
    RCMapAnnotation *annotation = [[RCMapAnnotation alloc] init];
    
    annotation.myLocation = self.location;
    annotation.title = self.location.name;
    annotation.coordinate = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
    [self.mapView addAnnotation:annotation];
    
    
   // MKPointAnnotation *userLocation = [[MKPointAnnotation alloc] init];
    //userLocation.coordinate = currentLocation;
    //[self.mapView addAnnotation:userLocation];
    
    [self.mapView setRegion:region animated:NO];
    self.mapView.showsUserLocation = YES;
    self.lbPrice.text = @"";
    for (int i = 0; i < self.location.price; ++i)
    {
        self.lbPrice.text = [NSString stringWithFormat:@"%@$", self.lbPrice.text];
    }
    
    //[self centerMap2];
    
    [super viewWillAppear:animated];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushWebView"])
    {
        RCWebViewController *webView = (RCWebViewController *)segue.destinationViewController;
        
        webView.url = sender;
    }
    
    if ([segue.identifier isEqualToString:@"PushDirection"])
    {
        RCDirectViewController *dirrect = (RCDirectViewController *) segue.destinationViewController;
        dirrect.location = self.location;
    }
}

#pragma mark -
#pragma mark - Webservice

- (void)callAPIGetListReview
{
    // Start new request
    NSString *urlString = [NSString stringWithFormat:kAPIGetComment, self.location.ID, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"callAPIGetListReview  url %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"callAPIGetListReview  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@", rO);
        
        self.listComment = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [rO objectForKey:@"comments"])
        {
            if([dic objectForKey:@"id"] != [NSNull null])
            {
                RCReview *review = [[RCReview alloc] init];
                review.content = [dic objectForKey:@"comment"];
                review.image = [dic objectForKey:@"photo"];
                if (review.image == nil || [dic objectForKey:@"photo"] == [NSNull null])
                {
                    review.image = nil;
                }
                
                [self.listComment addObject:review];
            }
           
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([self.listComment count] == 0)
        {
            self.lbNoReview.hidden = NO;
            self.tbReview.hidden = YES;
            self.lbReviews.hidden = YES;
        } else {
            self.tbReview.hidden = NO;
            self.lbReviews.hidden = NO;
            self.lbNoReview.hidden = YES;
        }
        
        [self.tbReview reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnBackTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnReviewTouched:(id)sender
{
    self.reviewVc = [[RCReviewInDetailsViewController alloc] initWithNibName:@"RCReviewInDetailsViewController" bundle:nil];
    self.reviewVc.vsParrent = self;
    self.reviewVc.location = self.location;
    self.reviewVc.shouldSendImmediately = YES;
    //[self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
    
    [self presentSemiModalViewController:self.reviewVc];
}

- (IBAction)btnCallTouched:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to call to %@", self.location.phoneNumber] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
    [alert show];
}

- (IBAction)btnReserveTouched:(id)sender
{
    // Start new request
    NSString *urlString = [NSString stringWithFormat:@"http://opentable.heroku.com/api/restaurants?name=%@&zip=%@", [self.location.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] , self.location.zipCode];
    
    urlString = [NSString stringWithFormat:@"http://opentable.heroku.com/api/restaurants?zip=%@&name=%@",self.location.zipCode, [self.location.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"reserve url: %@", urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@", rO);
        
        if ([[rO objectForKey:@"restaurants"] count] == 0)
        {
            [RCCommonUtils showMessageWithTitle:@"Failed" andContent:@"Reserving is not available."];
        } else {
            // Open Webview
            NSString *stringUrl = [[[rO objectForKey:@"restaurants"] objectAtIndex:0] objectForKey:@"mobile_reserve_url"];
            [self performSegueWithIdentifier:@"PushWebView" sender:stringUrl];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
}

- (IBAction)btnDirectionTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushDirection" sender:nil];
}

- (void)callPhone:(NSString *)tel
{
    NSLog(@"CALL PHONE %@", tel);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", tel]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark -
#pragma mark - AlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self callPhone:self.location.phoneNumber];
    }
}

#pragma mark -
#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCReview *review = [self.listComment objectAtIndex:indexPath.row];

    
    return [self getLabelSize:review.content fontSize:13] + 15;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.listComment count];
}


-(CGFloat)getLabelSize:(NSString *)text fontSize:(NSInteger)fontSize
{
    if(text != [NSNull null])
    {
        UIFont *cellFont = [UIFont boldSystemFontOfSize:fontSize];
        CGSize constraintSize = CGSizeMake(243, MAXFLOAT);
        CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelSize.height;
    }
    else
    {
        return 20;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
    
    RCReview *review = [self.listComment objectAtIndex:indexPath.row];
    
    if (review.content != [NSNull null]) {
        [(UILabel *)[cell viewWithTag:1003] setText:review.content];
        
        ((UILabel *)[cell viewWithTag:1003]).frame = CGRectMake(((UILabel *)[cell viewWithTag:1003]).frame .origin.x, ((UILabel *)[cell viewWithTag:1003]).frame .origin.y, 243, [self getLabelSize:review.content fontSize:13]);
        
        
        UIImageView *img = (UIImageView *)[cell viewWithTag:1001];
        [img setImageWithURL:[NSURL URLWithString:review.image] placeholderImage:[UIImage imageNamed:@"ic_me.png"]];
        
        if (indexPath.row % 2 == 0) {
            [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
        } else {
            [cell.contentView setBackgroundColor:kRCBackgroundView];
        }
    }
    
   
    
    return cell;
}


- (void)viewDidUnload {
    [self setBtnVibe:nil];
    [super viewDidUnload];
}
@end
