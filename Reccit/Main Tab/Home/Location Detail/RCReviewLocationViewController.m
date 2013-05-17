//
//  RCReviewLocationViewController.m
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCReviewLocationViewController.h"
#import "MBProgressHUD.h"
#import "RCDefine.h"
#import "RCCommonUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "RCAddPlaceViewController.h"
#import "RCRateViewController.h"
#define kRCAPIUpdateComment @"http://bizannouncements.com/bhavesh/reviewsupdate.php"
#define kRCAPIAddPlace @"http://bizannouncements.com/Vega/services/app/appCheckin.php"
@interface RCReviewLocationViewController ()

@end

@implementation RCReviewLocationViewController

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
    
    _viewRound.layer.cornerRadius = 5;
    _viewRound.layer.borderWidth = 1;
    _viewRound.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.recommendation = YES;
    self.rateView.editable = YES;
    
    self.btnLike.alpha = 0.3;
    self.btnUnLike.alpha = 0.3;
    
    [self.tvReview becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button touched






- (IBAction)btnSubmitTouched:(id)sender
{
    
    if(self.shouldSendImmediately)
    {
        if(self.location.ID > 0)
        {
            NSString *urlString = [NSString stringWithFormat:@"%@?reviews=%@", kRCAPIUpdateComment, [self makeString]];
            NSLog(@"REQUEST URL: %@", urlString);
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            
            NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            self.request = [ASIHTTPRequest requestWithURL:url];
            [self.request setRequestMethod:@"POST"];
            [self.request setCompletionBlock:^{
                
                NSLog(@"%@", [[NSString alloc] initWithData:[self.request responseData] encoding:NSUTF8StringEncoding]);
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
                NSLog(@"responseObject %@", responseObject);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                
                if([self.vsParrent isKindOfClass:[RCRateViewController class]])
                {
                    [((RCRateViewController *)self.vsParrent) callAPIGetListLocationRate];
                   
                }
                
                
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your review has been submitted!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alerView show];
            }];
            
            [self.request setFailedBlock:^{
                [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
            
            [self.request startAsynchronous];
        }
        else
        {
            NSString *urlString = [NSString stringWithFormat:@"%@?%@",kRCAPIAddPlace, [self makeString2]];
            NSLog(@"REQUEST URL kRCAPIAddPlace: %@", urlString);
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            
            NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            self.request = [ASIHTTPRequest requestWithURL:url];
            [self.request setRequestMethod:@"POST"];

            [self.request setCompletionBlock:^{
                
                NSLog(@"%@", [[NSString alloc] initWithData:[self.request responseData] encoding:NSUTF8StringEncoding]);
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[self.request responseData] options:kNilOptions error:nil];
                NSLog(@"responseObject %@", responseObject);
                
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your review has been submitted!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alerView show];
            }];
            
            [self.request setFailedBlock:^{
                [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
            
            [self.request startAsynchronous];

        }
    }
    else
    {
        if([self.vsParrent isKindOfClass:[RCAddPlaceViewController class]])
        {
            ((RCAddPlaceViewController *)self.vsParrent).reviewString = [self makeString2];
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your review saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alerView show];
        }
    }
    
    
}

-(NSString *)makeStringWithKeyAndValue:(NSString *)key value:(NSString *)value
{

    return [NSString stringWithFormat:@"\"%@\":\"%@\"", key, value];



}

-(NSString *)makeStringWithKeyAndValue2:(NSString *)key value:(NSString *)value
{
    
    return [NSString stringWithFormat:@"\"%@\":%@", key, value];
    
    
    
}


-(NSString *)makeString
{
    
    
    int i = (int)self.rateView.rate;
    if(i == 0)
        i = 1;
    NSArray *arr = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"placeid" value:[NSString stringWithFormat:@"%i", self.location.ID]],
                                             [self makeStringWithKeyAndValue:@"comment" value:self.tvReview.text],
                                             [self makeStringWithKeyAndValue2:@"rating" value:[NSString stringWithFormat:@"%i", i]],
                                             [self makeStringWithKeyAndValue:@"reccit" value:self.recommendation ? @"true" : @"false"],
                                             nil];



    NSString *clock = [NSString stringWithFormat:@"\"reviews\":[{%@}]", [arr componentsJoinedByString:@","]];



    NSString *abouttimeuser = [NSString stringWithFormat:@"\"userid\":%@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];

    NSString *contents = [NSString stringWithFormat:@"{%@,%@}", abouttimeuser, clock];
    NSLog(@"%@", [contents stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"%@", contents );

    return contents;
}

-(NSString *)makeString2
{
    
    
    int i = (int)self.rateView.rate;
    if(i == 0)
        i = 1;
    
    //json_place={ "user":1, "name":"The Horsebox", "address":"233rd Streeth", "city":"New York", "state":"NY", "country" : "USA", "lat": "40.730094", "long": "-73.979527", "rating":"4", "recommend": true, "comment": " this place is so good"}
    
    NSArray *arr = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"user" value:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]],
                    [self makeStringWithKeyAndValue:@"name" value:self.location.name],
                    [self makeStringWithKeyAndValue2:@"rating" value:[NSString stringWithFormat:@"%i", i]],
                    [self makeStringWithKeyAndValue:@"recommend" value:self.recommendation ? @"true" : @"false"],
                    [self makeStringWithKeyAndValue:@"comment" value:self.tvReview.text],
                    [self makeStringWithKeyAndValue:@"address" value:self.location.address],
                    [self makeStringWithKeyAndValue:@"city" value:self.location.city],
                    [self makeStringWithKeyAndValue:@"state" value:self.location.state],
                    [self makeStringWithKeyAndValue:@"country" value:self.location.country],
                    [self makeStringWithKeyAndValue:@"lat" value:[NSString stringWithFormat:@"%f",self.location.latitude]],
                    [self makeStringWithKeyAndValue:@"long" value:[NSString stringWithFormat:@"%f",self.location.longitude]],
                    nil];
    
    
    
    NSString *clock = [NSString stringWithFormat:@"json_place={%@}", [arr componentsJoinedByString:@","]];
    
    
    
    NSLog(@"%@", [clock stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"%@", clock );
    
    return clock;
}







-(NSMutableData *)buildAddChaingeString
{
    
    NSMutableString *sendStr = [[NSMutableString alloc] initWithString:@""];
    
    NSDictionary *review = @{@"placeid" : [NSString stringWithFormat:@"%i", self.location.ID], @"rating" : [NSString stringWithFormat:@"%f", self.rateView.rate], @"comment" : self.tvReview.text, @"reccit" : self.recommendation ? @"true" : @"false"};
    
    NSArray *reviews = @[review];
    
    NSDictionary *result = @{@"userid": [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"reviews" : reviews};
    //return [sendStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", result);
    NSMutableData *jsonData = [[NSJSONSerialization dataWithJSONObject:result options:0  error:nil] mutableCopy];
    
    return jsonData;
    
}


- (IBAction)btnCancelTouched:(id)sender
{
    [self.vsParrent dismissSemiModalViewController:self];
}

- (IBAction)btnLikeTouched:(id)sender
{
    self.btnLike.alpha = 1;
    self.btnUnLike.alpha = 0.3;
    self.recommendation = YES;
}

- (IBAction)btnUnLikeTouched:(id)sender
{
    self.recommendation = NO;
    self.btnUnLike.alpha = 1;
    self.btnLike.alpha = 0.3;
}

#pragma mark -
#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self btnCancelTouched:nil];
}

- (void)viewDidUnload {
    [self setViewRound:nil];
    [super viewDidUnload];
}
@end
