//
//  RCReviewLocationViewController.m
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCReviewInDetailsViewController.h"
#import "MBProgressHUD.h"
#import "RCDefine.h"
#import "RCCommonUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "RCAddPlaceViewController.h"
#import "RCRateViewController.h"
#import "RCVibeHelper.h"
#import "RCAppDelegate.h"
#import "RCShareViewController.h"
#define kRCAPIUpdateComment @"http://bizannouncements.com/bhavesh/reviewsupdate.php"
#define kRCAPIAddPlace @"http://bizannouncements.com/Vega/services/app/appCheckin.php"

#define kRCAPIAddPlaceDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/checkin/checkin.svc/UpdateReview"
#define kRCAPIUpdateCommentInRate @"http://bizannouncements.com/bhavesh/updatereview.php?userid=%@&placeid=%d&recommend=%@&rating=%lf&review=%@"

@interface RCReviewInDetailsViewController ()

@end

@implementation RCReviewInDetailsViewController

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
    //_isDelta = NO;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
        //}];
        
    }
    
    if(![RCCommonUtils isIphone5])
    {
        CGRect rect = self.tvReview.frame;
        rect.size.height = rect.size.height - 40;
        self.tvReview.frame = rect;
        
        rect = self.backForText.frame;
        rect.size.height = rect.size.height - 40;
        self.backForText.frame = rect;
        
        rect = self.btnDone.frame;
        rect.origin.y = rect.origin.y - 40;
        self.btnDone.frame = rect;
    }
    
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideConversationButton];
    
    UIColor *bg = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    self.view.backgroundColor = bg;
	// Do any additional setup after loading the view.
    
    //_viewRound.layer.cornerRadius = 5;
    //_viewRound.layer.borderWidth = 1;
    //_viewRound.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.recommendation = YES;
    self.rateView.editable = YES;
    if([self.location.recommendation isEqualToString:@"YES"])
    {
        self.btnLike.alpha = 1;
        self.btnUnLike.alpha = 0.3;
    }
    else
    {
        if([self.location.recommendation isEqualToString:@"NO"])
        {
            self.btnLike.alpha = 0.3;
            self.btnUnLike.alpha = 1;
        }
        else
        {
            self.btnLike.alpha = 0.3;
            self.btnUnLike.alpha = 0.3;
        }
      
    }
    _lblPlaceName.text = self.location.name;
    if([self.vsParrent isKindOfClass:[RCShareViewController class]])
    {
        self.tvReview.editable = NO;
        self.rateView.editable = NO;
        self.btnDone.hidden = YES;
        self.tvReview.text = self.location.comment;
    }
    else
    {
        if([self.vsParrent isKindOfClass:[RCAddPlaceViewController class]] && !self.shouldSendImmediately)
        {
            //[self sendReview];
            self.btnLike.hidden = YES;
            self.btnUnLike.hidden = YES;

        }
        
        
        self.btnEdit.hidden = YES;
        [self.tvReview becomeFirstResponder];

    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button touched




-(void)sendReview
{

        NSString *urlString = [NSString stringWithFormat:@"%@",kRCAPIAddPlaceDOTNET];
        
        NSLog(@"REQUEST URL: %@", urlString);
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        /*if(self.isDelta == YES)
        {
            urlString = [NSString stringWithFormat:kRCAPIUpdateCommentInRate, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], self.location.ID, self.recommendation == YES ? @"yes" : @"no", self.rateView.rate, self.tvReview.text];
            NSLog(@"REQUEST URL: %@", urlString);
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            // Start new request
            url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }*/
        
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
        [client setParameterEncoding:AFJSONParameterEncoding];

        
        [client postPath:@"" parameters:@{@"review":[RCCommonUtils buildReviewString:self.location]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"sendReview response = %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            NSLog(@"responseObject %@", rO);
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            
            if([self.vsParrent isKindOfClass:[RCRateViewController class]])
            {
                [((RCRateViewController *)self.vsParrent) callAPIGetListLocationRate];
                
            }
            if([self.vsParrent isKindOfClass:[RCShareViewController class]])
            {
                [((RCShareViewController *)self.vsParrent) startRequest];
                
            }
            RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showButtonForMessages];
            
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your review has been submitted!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alerView show];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"sendReview error: %@", error.description);
            
            //RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
            //[appDelegate showButtonForMessages];
            [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
        

}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 140) ? NO : YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
	int maxChars = 140;
	int charsLeft = maxChars - [textView.text length];
    
	if(charsLeft == 0) {
		UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No more characters"
                                                         message:[NSString stringWithFormat:@"You have reached the character limit of %d.",maxChars]
                                                        delegate:nil
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
		[alert show];
	}
    
	self.lblLettersCount.text = [NSString stringWithFormat:@"%d characters left",charsLeft];
}

- (IBAction)btnSubmitTouched:(id)sender
{
    self.location.comment = self.tvReview.text;
    NSLog(@"btnSubmitTouched %@", self.location.comment);
    

    [[RCVibeHelper sharedInstance] addUserToPlaceTalk:[[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] integerValue] placeId:self.location.ID completionBlock:^(BOOL result, NSError *error) {
        if(result)
        {
            NSLog(@"Success!");
            
        }
        else
        {
            NSLog(@"error in addUserToPlaceTalk %@", error.description);
        }
    }];
    if(self.shouldSendImmediately)
    {
        [self sendReview];
        
    }
    else
    {
        if([self.vsParrent isKindOfClass:[RCAddPlaceViewController class]])
        {
            //[self sendReview];
            
            
            ((RCAddPlaceViewController *)self.vsParrent).reviewString = self.tvReview.text;
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your mention has been saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alerView show];
            RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showButtonForMessages];
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
                    [self makeStringWithKeyAndValue:@"genre" value:self.location.genre],
                    [self makeStringWithKeyAndValue:@"type" value:self.location.category],
                    [self makeStringWithKeyAndValue:@"street" value:self.location.street],
                    [self makeStringWithKeyAndValue:@"phone" value:self.location.phoneNumber],
                    [self makeStringWithKeyAndValue2:@"place_id" value:[NSString stringWithFormat:@"%i", self.location.ID > 0 ? self.location.ID : 0]],


                    nil];
    
    
    
    NSString *clock = [NSString stringWithFormat:@"json_place={%@}", [arr componentsJoinedByString:@","]];
    
    
    
    //NSLog(@"%@", [clock stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"%@", clock );
    
    return clock;
}







-(NSMutableData *)buildAddChaingeString
{
    
   // NSMutableString *sendStr = [[NSMutableString alloc] initWithString:@""];
    
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
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showButtonForMessages];
    [self.vsParrent dismissSemiModalViewController:self];
}

- (IBAction)btnEditTouched:(id)sender
{
    self.btnDone.hidden = NO;
    self.btnEdit.hidden = YES;
    self.tvReview.editable = YES;
    self.rateView.editable = YES;
}

- (IBAction)btnLikeTouched:(id)sender
{
    if([self.vsParrent isKindOfClass:[RCShareViewController class]] && !self.btnEdit.hidden)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please tap edit button to make any changes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.tag = 1001;

        [alert show];
        return;
        
    }
    else
    {
        self.btnLike.alpha = 1;
        self.btnUnLike.alpha = 0.3;
        self.recommendation = YES;
        self.location.recommendation = @"YES";
        
    }

}

- (IBAction)btnUnLikeTouched:(id)sender
{
    if([self.vsParrent isKindOfClass:[RCShareViewController class]] && !self.btnEdit.hidden)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please tap edit button to make any changes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.tag = 1001;
        [alert show];
        return;
        
    }
    else
    {
        self.recommendation = NO;
        self.location.recommendation = @"NO";
        self.btnUnLike.alpha = 1;
        self.btnLike.alpha = 0.3;
    }

}
#pragma mark -
#pragma mark - AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag != 1001)
    {
        [self btnCancelTouched:nil];

    }
}

- (void)viewDidUnload {
    [self setViewRound:nil];
    [self setLblPlaceName:nil];
    [self setBackForText:nil];
    [self setBtnDone:nil];
    [self setBtnEdit:nil];
    [super viewDidUnload];
}
@end
