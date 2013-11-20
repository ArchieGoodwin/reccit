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
#import "AFNetworking.h"
#import "RCAppDelegate.h"
//#define kAPISearchSurprise @"http://bizannouncements.com/Vega/services/app/recommendation.php?%@"

#define kAPISearchSurprise @"http://bizannouncements.com/Vega/services/app/getReccit.php?%@"
#define kAPISearchSurpriseDOTNET  @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/GetFactual?%@"
@interface RCSurpriseViewController ()
{
    int weekday;
}
@end

@implementation RCSurpriseViewController

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

-(void)clearHappyHours
{
    NSMutableArray *temp = [NSMutableArray new];
    
    for(RCLocation *loc in self.listLocation)
    {
        if(![[self getHappyHour:loc] isEqualToString:@""])
        {
            [temp addObject:loc];
        }
    }
    
    [self.listLocation removeAllObjects];
    [self.listLocation addObjectsFromArray:temp];
}


-(NSString *)distanceStringFromPoint:(RCLocation *)myLocation
{
    CFLocaleRef userLocaleRef = CFLocaleCopyCurrent();
    //CFShow(CFLocaleGetIdentifier(userLocaleRef));
    NSString *loc = (NSString *)CFLocaleGetIdentifier(userLocaleRef);
    CFRelease(userLocaleRef);
    double kilometers = myLocation.distance;
    //kilometers = 1.4;
    double res = 0.0;
    if([loc isEqualToString:@"en_US"] || [loc isEqualToString:@"en_GB"])
    {
        loc = @"en_US";
    }
    if([loc isEqualToString:@"en_US"])
    {
        res = kilometers / 1609.344;
    }
    else
    {
        res = kilometers / 1000;
    }
    
    NSString *str  = @"";
    if(res > 1)
    {
        str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.1f %@", res, [loc isEqualToString:@"en_US"] ? @"miles" : @"km"]];
    }
    else
    {
        str = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%.1f %@", (res * ([loc isEqualToString:@"en_US"] ? 5280 : 1000)), [loc isEqualToString:@"en_US"] ? @"feets" : @"m"]];
    }
    return str;
}


- (void)callAPIGetListLocation
{
    // Start new request
    NSString *urlString = [NSString stringWithFormat:kAPISearchSurpriseDOTNET, self.querySearch];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"happy hours url: %@", urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
       //NSLog(@"happy hours: %@", str);
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        /*if([str hasPrefix:@"hi"])
         {
         str = [str substringFromIndex:2];
         responseObject = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
         }*/
        
        
        
        //NSLog(@"happy hour: %@", responseObject);
        self.listLocation = [[NSMutableArray alloc] init];
        if (self.isHappyHour)
        {
            NSArray * rObject = [rO objectForKey:@"GetFactualResult"];
            for (NSDictionary *category in rObject)
            {
                NSLog(@"%@", category);
                
                NSLog(@"%@", category);
                RCLocation *l = [RCCommonUtils getLocationFromDictionary:category];
                if(l)
                {
                    [self.listLocation addObject:l];
                    
                }
                
            }
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];

            [self.listLocation sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            
            [self clearHappyHours];
        } else {
            for (NSDictionary *category in rO)
            {
                for (NSDictionary *locationDic in [rO objectForKey:[category description]])
                {
                    RCLocation *l = [RCCommonUtils getLocationFromDictionary:locationDic];
                    if(l)
                    {
                        [self.listLocation addObject:l];
                        
                    }
                    
                }
            }
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([self.listLocation count] == 0)
        {
            [RCCommonUtils showMessageWithTitle:nil andContent:@"No results for your search."];
        }
        [self.tbResult reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    

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
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
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
        
        if(loc.happyhours.count > 0)
        {
            return loc.happyhours[weekday - 1];

        }
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
    
    [(UILabel *)[cell viewWithTag:505] setText:[self distanceStringFromPoint:location]];

    
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
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
    
    RCLocation *location = [self.listLocation objectAtIndex:indexPath.row];
    
    NSLog(@"%@", location.name);
    [self performSegueWithIdentifier:@"PushDetail" sender:location];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
