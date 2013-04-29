//
//  RCSurpriseViewController.m
//  Reccit
//
//  Created by Lee Way on 1/31/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCSurpriseViewController.h"
#import "RCDefine.h"
#import "RCCommonUtils.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "RCLocation.h"
#import "DYRateView.h"
#import "RCLocationDetailViewController.h"

//#define kAPISearchSurprise @"http://bizannouncements.com/Vega/services/app/recommendation.php?%@"

#define kAPISearchSurprise @"http://bizannouncements.com/Vega/services/app/getReccit.php?%@"

@interface RCSurpriseViewController ()
{
    int weekday;
}
@end

@implementation RCSurpriseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:1];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    weekday = [comps weekday];
    NSLog(@"week day: %i", weekday);
    
    // Uncomment the following line to preserve selection between presentations.
    
    [self performSelector:@selector(callAPIGetListLocation) withObject:nil afterDelay:0.2];
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    [self.tbResult setSeparatorColor:[UIColor clearColor]];
    [self.tbResult setBackgroundColor:[UIColor clearColor]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushDetail"])
    {
        RCLocationDetailViewController *detail = (RCLocationDetailViewController *)segue.destinationViewController;
        
        detail.location = sender;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.isHappyHour)
    {
        self.imgHappyHour.hidden = YES;
    }
}

#pragma mark -
#pragma mark - Webservice

- (void)callAPIGetListLocation
{
    // Start new request
    NSString *urlString = [NSString stringWithFormat:kAPISearchSurprise, self.querySearch];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.request = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"REQUEST : %@", urlString);
    
    [self.request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
        //NSLog(@"happy hour: %@", responseObject);
        self.listLocation = [[NSMutableArray alloc] init];
        if (self.isHappyHour)
        {
            NSArray * rObject = [responseObject objectForKey:@"Reccits"];
            for (NSDictionary *category in rObject)
            {
                NSLog(@"%@", category);

                    NSLog(@"%@", category);
                    [self.listLocation addObject:[RCCommonUtils getLocationFromDictionary:category]];
               
            }
        } else {
            for (NSDictionary *category in responseObject)
            {
                for (NSDictionary *locationDic in [responseObject objectForKey:[category description]])
                {
                    [self.listLocation addObject:[RCCommonUtils getLocationFromDictionary:locationDic]];
                }
            }
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([self.listLocation count] == 0)
        {
            [RCCommonUtils showMessageWithTitle:nil andContent:@"No result for this searching."];
        }
        [self.tbResult reloadData];
    }];
    
    [self.request setFailedBlock:^{
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [self.request startAsynchronous];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnBackTouched:(id)sender
{
    if (self.isHappyHour)
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                         }
                         completion:^(BOOL finished){
                             [self.navigationController popViewControllerAnimated:NO];
                         }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.listLocation count];;
}


-(NSString *)getHappyHour:(RCLocation *)loc
{
    if(loc.happyhours)
    {
        return loc.happyhours[weekday - 1];
    }

    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    
    RCLocation *location = [self.listLocation objectAtIndex:indexPath.row];
    
    /*[(UILabel *)[cell viewWithTag:1001] setText:location.name];
    
    DYRateView *rateView = (DYRateView *)[cell viewWithTag:1002];
    
    [rateView setRate:location.rating];
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }*/
    
     [(UILabel *)[cell viewWithTag:6000] setText:[self getHappyHour:location]];
    
    
    if(location.listFriends.count > 0)
    {
        [(UILabel *)[cell viewWithTag:996] setText:[NSString stringWithFormat:@"%i of your friends have been there", location.listFriends.count]];
        
    }
    else
    {
        [(UILabel *)[cell viewWithTag:996] setText:@""];
    }
    if(location.reccitCount > 0)
    {
        [(UILabel *)[cell viewWithTag:997] setText:[NSString stringWithFormat:@"%i reccits", location.reccitCount]];
        
    }
    else
    {
        [(UILabel *)[cell viewWithTag:997] setText:@""];
    }
    
    
    
    [(UILabel *)[cell viewWithTag:1001] setText:location.name];
    
    DYRateView *rateView = (DYRateView *)[cell viewWithTag:1002];
    
    [rateView setRate:location.rating];
    
    if (indexPath.row % 2 == 0) {
        [cell.contentView setBackgroundColor:kRCCheckInCellColorHighLight];
    } else {
        [cell.contentView setBackgroundColor:kRCBackgroundView];
    }
    
    for (int i = 0; i < 8; ++i)
    {
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:2001+i];
        imgView.image = nil;
    }
    if (location.listFriends != nil && [location.listFriends count] > 0)
    {
        for (int i = 0; i < [location.listFriends count]; ++i)
        {
            NSString *imgUrl = [location.listFriends objectAtIndex:i];
            UIImageView *imgView = (UIImageView *)[cell viewWithTag:2001+i];
            [imgView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
        }
    }
    ((UIImageView *)[cell viewWithTag:995]).hidden = YES;
    if(location.reccitCount > 0)
    {
        ((UIImageView *)[cell viewWithTag:995]).hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCLocation *location = [self.listLocation objectAtIndex:indexPath.row];
    
    NSLog(@"%@", location.name);
    [self performSegueWithIdentifier:@"PushDetail" sender:location];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
