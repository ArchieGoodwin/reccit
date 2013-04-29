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
#import "RCReviewLocationViewController.h"
#import "RCRateCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RCDefine.h"

#define kRCAPICheckInGetLocationRate @"http://bizannouncements.com/bhavesh/deltaservice.php?userid=%@"

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

    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastDate"];


    self.listLocation = [[NSMutableArray alloc] init];
    [self performSelector:@selector(callAPIGetListLocationRate) withObject:nil afterDelay:0.1f];
    
    self.tbLocation.layer.borderWidth = 1.5f;
    self.tbLocation.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.view setBackgroundColor:kRCBackgroundView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    NSString *urlString = [NSString stringWithFormat:kRCAPICheckInGetLocationRate, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    NSLog(@"REQUEST URL: %@", urlString);
    
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Start new request
    NSURL *url = [NSURL URLWithString:urlString];
    self.request = [ASIHTTPRequest requestWithURL:url];
    
    [self.request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
        NSLog(@"%@", responseObject);
        [self.listLocation removeAllObjects];
        for (NSDictionary *locationDic in responseObject)
        {
            RCLocation *location = [RCCommonUtils getLocationFromDictionary:locationDic];
            location.ID = [[locationDic objectForKey:@"id"] intValue];
            [self.listLocation addObject:location];
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
    
    [self.request setFailedBlock:^{
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    [self.request startAsynchronous];
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
    self.reviewVc = [[RCReviewLocationViewController alloc] initWithNibName:@"RCReviewLocationViewController" bundle:nil];
    self.reviewVc.vsParrent = self;
    self.reviewVc.location = location;
    self.reviewVc.shouldSendImmediately = YES;

    [self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
    
    [self presentSemiModalViewController:self.reviewVc];
}

- (IBAction)btnLikeTouched:(id)sender
{
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
    NSLog(@"%@", location.address);
    
    if(location.address)
    {
        if(![location.address isEqualToString:@"(null)"])
        {
            cell.lbAddress.text = location.address;

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
    self.reviewVc = [[RCReviewLocationViewController alloc] initWithNibName:@"RCReviewLocationViewController" bundle:nil];
    self.reviewVc.vsParrent = self;
    self.reviewVc.location = location;
    self.reviewVc.shouldSendImmediately = YES;
    [self.reviewVc.view setBackgroundColor:[UIColor clearColor]];
    
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
