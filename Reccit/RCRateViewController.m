//
//  RCRateViewController.m
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCRateViewController.h"
#import "RCCommonUtils.h"
#import "RCLocation.h"
#import "MBProgressHUD.h"
#import "DYRateView.h"
#import "RCReviewInDetailsViewController.h"
#import "RCRateCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RCDefine.h"
#import "AFNetworking.h"
#define kRCAPICheckInGetLocationRate @"http://bizannouncements.com/bhavesh/deltaservice.php?userid=%@"
#define kRCAPICheckInGetLocationRateDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/services/Reccit.svc/delta?userfbid=%@"


@interface RCRateViewController ()

@end

@implementation RCRateViewController

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

    if(![[NSUserDefaults standardUserDefaults] objectForKey:kRCFirstTimeLogin])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kRCFirstTimeLogin];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }

    
    
    //[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastDate"];


    self.listLocation = [[NSMutableArray alloc] init];
    //[self performSelector:@selector(callAPIGetListLocationRate) withObject:nil afterDelay:0.1f];
    
    self.tbLocation.layer.borderWidth = 1.5f;
    self.tbLocation.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.view setBackgroundColor:kRCBackgroundView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"view" withAction:@"viewWillAppear" withLabel:@"RCRateViewController" withValue:nil];
    [self callAPIGetListLocationRate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Webservice

- (void)callAPIGetListLocationRate
{
    NSString *urlString = [NSString stringWithFormat:kRCAPICheckInGetLocationRateDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    NSLog(@"REQUEST URL: %@", urlString);
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Start new request
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"%@", rO);

        [self.listLocation removeAllObjects];
        for (NSDictionary *locationDic in [rO objectForKey:@"DeltaResult"])
        {
            RCLocation *location = [RCCommonUtils getLocationFromDictionary:locationDic];
            if(location)
            {
                location.ID = [[locationDic objectForKey:@"id"] intValue];
                [self.listLocation addObject:location];
            }
            
        }
        
        if ([self.listLocation count] == 0)
        {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self performSelector:@selector(noRateLocation) withObject:nil afterDelay:0.0];
            
            //self.HUD.customView = nil;
            //self.HUD.mode = MBProgressHUDModeCustomView;
            //self.HUD.labelText = @"There's no recommend place for you";
            //self.HUD.labelFont = [UIFont boldSystemFontOfSize:12];
        } else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tbLocation reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [operation start];
    
    
    
    
    
    
    
    

    /*
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:nil];
        NSLog(@"%@", responseObject);
        [self.listLocation removeAllObjects];
        for (NSDictionary *locationDic in responseObject)
        {
            RCLocation *location = [RCCommonUtils getLocationFromDictionary:locationDic];
            if(location)
            {
                location.ID = [[locationDic objectForKey:@"id"] intValue];
                [self.listLocation addObject:location];
            }

        }
        
        if ([self.listLocation count] == 0)
        {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self performSelector:@selector(noRateLocation) withObject:nil afterDelay:0.0];

            //self.HUD.customView = nil;
            //self.HUD.mode = MBProgressHUDModeCustomView;
            //self.HUD.labelText = @"There's no recommend place for you";
            //self.HUD.labelFont = [UIFont boldSystemFontOfSize:12];
        } else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tbLocation reloadData];
        }
    }];
    
    [request setFailedBlock:^{
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    request.timeOutSeconds = 20;
    [request startAsynchronous];*/
}

- (void)noRateLocation
{
    [MBProgressHUD hideHUDForView:self.tbLocation animated:YES];
    [self performSegueWithIdentifier:@"PushHome" sender:nil];
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnRateTouched:(id)sender
{
    UIButton *btnLocation = (UIButton *)sender;
    RCLocation *location = [self.listLocation objectAtIndex:btnLocation.tag];
    self.reviewVc = [[RCReviewInDetailsViewController alloc] initWithNibName:@"RCReviewInDetailsViewController" bundle:nil];
    self.reviewVc.vsParrent = self;
    self.reviewVc.location = location;
    self.reviewVc.shouldSendImmediately = YES;
    self.reviewVc.isDelta = YES;
    //[self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
    
    [self presentSemiModalViewController:self.reviewVc];
}

- (IBAction)btnLikeTouched:(id)sender
{
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(menuButtonClicked)];

    
//    UIButton *btn = (UIButton *)sender;
//    RCLocation *location = [self.listLocation objectAtIndex:btn.tag];
//    location.recommendation = YES;
//    [self.tbLocation reloadData];
}

- (IBAction)btnUnLikeTouched:(id)sender
{
//    UIButton *btn = (UIButton *)sender;
//    RCLocation *location = [self.listLocation objectAtIndex:btn.tag];
//    location.recommendation = NO;
//    [self.tbLocation reloadData];
}


- (IBAction)btnDoneTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushHome" sender:nil];

    //[self callAPIGetListLocationRate];
}

- (IBAction)btnSkipTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushHome" sender:nil];
}

#pragma mark -
#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listLocation count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCRateCell *cell = (RCRateCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    RCLocation *location = [self.listLocation objectAtIndex:indexPath.row];
    cell.lbName.text = location.name;
    NSLog(@"%@, %@", location.city, location.address);
    
    if(location.address)
    {
        if(![location.address isEqualToString:@"(null)"])
        {
            cell.lbAddress.text = [NSString stringWithFormat:@"%@, %@", location.city, location.address];

        }
    }
    
    
    [cell.btnReview setTag:indexPath.row];
    //[cell.btnLike setTag:indexPath.row];
    //[cell.btnUnLike setTag:indexPath.row];
    
    //cell.rateView.tag = indexPath.row;
//    cell.rateView.editable = YES;
    //cell.rateView.rate = location.rating;
//    cell.rateView.delegate = self;

    /*if (location.recommendation) {
        //cell.btnLike.alpha = 1.0;
        //cell.btnUnLike.alpha = 0.3;
        [cell.btnLike setImage:[UIImage imageNamed:@"btn-like-press.png"] forState:UIControlStateNormal];
        [cell.btnUnLike setImage:[UIImage imageNamed:@"btn-dislike.png"] forState:UIControlStateNormal];
    }else{
        //cell.btnLike.alpha = 0.3;
        //cell.btnUnLike.alpha = 1.0;
        [cell.btnLike setImage:[UIImage imageNamed:@"btn-like.png"] forState:UIControlStateNormal];
        [cell.btnUnLike setImage:[UIImage imageNamed:@"btn-dislike-press.png"] forState:UIControlStateNormal];
    }*/
    
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RCLocation *location = [self.listLocation objectAtIndex:indexPath.row];
    self.reviewVc = [[RCReviewInDetailsViewController alloc] initWithNibName:@"RCReviewInDetailsViewController" bundle:nil];
    self.reviewVc.vsParrent = self;
    self.reviewVc.location = location;
    self.reviewVc.shouldSendImmediately = YES;
    self.reviewVc.isDelta = YES;
    //[self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
    
    [self presentSemiModalViewController:self.reviewVc];
    
    
}

#pragma mark -
#pragma mark - DYRateView delegate

- (void)rateView:(DYRateView *)rateView changedToNewRate:(NSNumber *)rate
{
    //RCLocation *location = [self.listLocation objectAtIndex:rateView.tag];
    //location.rating = [rate doubleValue];
}

@end
