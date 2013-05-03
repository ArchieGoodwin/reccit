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
#import "RCReviewLocationViewController.h"
#import "RCDirectViewController.h"


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
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    [self performSelector:@selector(callAPIGetListReview) withObject:nil afterDelay:0.2];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.lbName.text = self.location.name;
    self.lbAddress.text = self.location.address;
    
    self.rateView.rate = self.location.rating;
    self.lbCity.text = self.location.city;
    
    if (self.location.phoneNumber == nil || [self.location.phoneNumber length] == 0)
    {
        self.btnCall.hidden = YES;
    }
    
    CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
    MKCoordinateRegion region = {{0,0},{.001,.001}};
    region.center = currentLocation;
    
    MKPointAnnotation *userLocation = [[MKPointAnnotation alloc] init];
    userLocation.coordinate = currentLocation;
    [self.mapView addAnnotation:userLocation];
    
    [self.mapView setRegion:region animated:NO];
    self.mapView.showsUserLocation = YES;
    
    self.lbPrice.text = @"";
    for (int i = 0; i < self.location.price; ++i)
    {
        self.lbPrice.text = [NSString stringWithFormat:@"%@$", self.lbPrice.text];
    }
    
    [super viewWillAppear:animated];
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
    self.request = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"REQUEST : %@", urlString);
    
    [self.request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
        NSLog(@"%@", [responseObject description]);
        
        self.listComment = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [responseObject objectForKey:@"comments"])
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
    }];
    
    [self.request setFailedBlock:^{
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [self.request startAsynchronous];
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnBackTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnReviewTouched:(id)sender
{
    self.reviewVc = [[RCReviewLocationViewController alloc] initWithNibName:@"RCReviewLocationViewController" bundle:nil];
    self.reviewVc.vsParrent = self;
    self.reviewVc.location = self.location;
    self.reviewVc.shouldSendImmediately = YES;
    [self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
    
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
    self.request = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"REQUEST : %@", urlString);
    
    [self.request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
        NSLog(@"%@", [responseObject description]);
        
        if ([[responseObject objectForKey:@"restaurants"] count] == 0)
        {
            [RCCommonUtils showMessageWithTitle:@"Failed" andContent:@"Reserving is not available."];
        } else {
            // Open Webview
            NSString *stringUrl = [[[responseObject objectForKey:@"restaurants"] objectAtIndex:0] objectForKey:@"mobile_reserve_url"];
            [self performSegueWithIdentifier:@"PushWebView" sender:stringUrl];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [self.request setFailedBlock:^{
        [RCCommonUtils showMessageWithTitle:@"Failed" andContent:@"Reserving is not available."];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [self.request startAsynchronous];
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
  
    UIFont *cellFont = [UIFont boldSystemFontOfSize:fontSize];
	CGSize constraintSize = CGSizeMake(243, MAXFLOAT);
	CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ReviewCell"];
    
    RCReview *review = [self.listComment objectAtIndex:indexPath.row];
    
    [(UILabel *)[cell viewWithTag:1003] setText:review.content];
    
    ((UILabel *)[cell viewWithTag:1003]).frame = CGRectMake(((UILabel *)[cell viewWithTag:1003]).frame .origin.x, ((UILabel *)[cell viewWithTag:1003]).frame .origin.y, 243, [self getLabelSize:review.content fontSize:13]);
    
    
    UIImageView *img = (UIImageView *)[cell viewWithTag:1001];
    [img setImageWithURL:[NSURL URLWithString:review.image] placeholderImage:[UIImage imageNamed:@"ic_me.png"]];
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    
    return cell;
}


@end
