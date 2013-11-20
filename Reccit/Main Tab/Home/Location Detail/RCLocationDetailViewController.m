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
#import "RCAppDelegate.h"
#define kAPIGetComment @"http://bizannouncements.com/Vega/data/places/comments.php?place_id=%d&user_id=%@"
#define kAPIGetCommentDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/GetComments?userfbid=%@&placeid=%d"
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

-(BOOL)prefersStatusBarHidden
{
    return YES;
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
    else
    {

            CGRect frame = self.tbReview.frame;
            frame.size.height = frame.size.height + 50;
            self.tbReview.frame = frame;

    }

   
	// Do any additional setup after loading the view.
    
    self.mapView.delegate = self;

    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    [self performSelector:@selector(callAPIGetListReview) withObject:nil afterDelay:0.2];
}

- (IBAction)btnVibeTap:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[RCVibeHelper sharedInstance] getConversationFromServer:self.location.ID completionBlock:^(RCConversation *result, NSError *error) {
        VibeViewController *controller = [[VibeViewController alloc] initWithNibName:@"VibeViewController" bundle:nil];
        controller.location = self.location;
        if(result != nil)
        {
            [RCConversation saveDefaultContext];
            
            if(result.placeName == nil)
            {
                result.placeName = self.location.name;
            }
            result.messagesCount = @"0";
            result.lastDate = [NSDate date];
            [RCConversation saveDefaultContext];

            controller.convsersation = result;
        }
        else
        {
            RCConversation *conv = [[RCVibeHelper sharedInstance] getConverationById:self.location.ID];;
            if(conv.placeName == nil)
            {
                conv.placeName = self.location.name;
            }
            conv.messagesCount = @"0";
            conv.lastDate = [NSDate date];
            [RCConversation saveDefaultContext];
            controller.convsersation = conv;
        }

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        
        
    }];
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self performSelector:@selector(showVibe) withObject:nil afterDelay:0.3];
    
    _btnVibe.hidden = NO;
    /*if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
    {
        if(self.location.ID > 0)
        {
            _btnVibe.hidden = NO;

        }
    }
    else
    {
        _btnVibe.hidden = YES;
    }*/
    if(self.location.ID > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
    {
        _btnVibe.hidden = NO;
        
    }
    else
    {
        _btnVibe.hidden = YES;
    }
    
    NSLog(@"loc address: %@  ;  %@ ", self.location.address, self.location.street);
    self.lbName.text = self.location.name;
    
    NSMutableString *textAll = [NSMutableString new];
    if(![self.location.genre isEqual:[NSNull null]] && self.location.genre != nil)
    {
        [textAll appendString:self.location.genre];
        [textAll appendString:@"\n"];
        //self.lbCity.text = self.location.genre;
        
    }
    if(![self.location.city isEqual:[NSNull null]] && self.location.city != nil)
    {
        
        [textAll appendString:[NSString stringWithFormat:@"%@ \n%@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.city, [self.location.state isEqualToString:@""] ? @"" : self.location.state,  self.location.zipCode ]];
        //self.lbAddress.text = [NSString stringWithFormat:@"%@ \n%@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.city, [self.location.state isEqualToString:@""] ? @"" : self.location.state,  self.location.zipCode ];

    }
    else
    {
        [textAll appendString:[NSString stringWithFormat:@"%@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.state, self.location.zipCode]];
        //self.lbAddress.text = [NSString stringWithFormat:@"%@ %@ %@",[self.location.street isEqualToString:@""] ? self.location.address : self.location.street, self.location.state, self.location.zipCode];

    }
    self.lbCity.text = textAll;
    self.rateView.rate = self.location.rating;
    
    
    if (self.location.phoneNumber == nil || [self.location.phoneNumber isEqualToString:@""])
    {
        self.btnCall.hidden = YES;
    }
    
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
    NSString *urlString = [NSString stringWithFormat:kAPIGetCommentDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], self.location.ID];
    
   // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"callAPIGetListReview  url %@", urlString);

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"callAPIGetListReview  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@", rO);
        
        self.listComment = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [rO objectForKey:@"GetCommentResult"])
        {
            if([dic objectForKey:@"id"] != [NSNull null])
            {
                RCReview *review = [[RCReview alloc] init];
                review.content = [dic objectForKey:@"comment"];

                review.image = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",[dic objectForKey:@"user_id"]];
                if (review.image == nil || [dic objectForKey:@"user_id"] == [NSNull null])
                {
                    review.image = nil;
                }
                
                [self.listComment addObject:review];
            }
           
        }
        
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        
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
        //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnBackTouched:(id)sender
{
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnReviewTouched:(id)sender
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
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
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

    
    return [self getLabelSize:review.content fontSize:13] + 18;
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
        CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
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
        
        ((UILabel *)[cell viewWithTag:1003]).frame = CGRectMake(((UILabel *)[cell viewWithTag:1003]).frame .origin.x, ((UILabel *)[cell viewWithTag:1003]).frame .origin.y, 243, [self getLabelSize:review.content fontSize:13] + 3);
        
        
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
