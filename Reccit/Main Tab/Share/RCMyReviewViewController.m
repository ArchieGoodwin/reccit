//
//  RCMyReviewViewController.m
//  Reccit
//
//  Created by Lee Way on 2/15/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCMyReviewViewController.h"
#import "RCDefine.h"
#import "UIImageView+WebCache.h"
#import "RCCommonUtils.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#define kRCAPIUpdateComment @"http://bizannouncements.com/bhavesh/updatereview.php?userid=%@&placeid=%d&recommend=%@&rating=%lf&review=%@"

@interface RCMyReviewViewController ()

@end

@implementation RCMyReviewViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    self.btnShare.hidden = YES;
    self.btnCancel.hidden = YES;
    self.rateView.editable = NO;
    self.txtComment.inputAccessoryView = self.toolbar;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.lbName.text = self.location.name;
    self.rateView.rate = self.location.rating;
    NSLog(@"%@, %f", self.location.recommendation, self.location.rating);
    NSLog(@"%@", self.location.comment);
    self.txtComment.text = self.location.comment;
    
    if ([self.location.recommendation isEqualToString:@"YES"] )
    {
        self.btnReccit.alpha = 1;
        self.btnNotReccit.alpha = 0.3;
    } else {
        if([self.location.recommendation isEqualToString:@"NO"])
        {
            self.btnReccit.alpha = 0.3;
            self.btnNotReccit.alpha = 1;
            
        }
        else
        {
            self.btnReccit.alpha = 0.3;
            self.btnNotReccit.alpha = 0.3;

        }
        
    }
    
    self.txtComment.editable = NO;
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnReccitTouched:(id)sender
{
    if(!self.btnEdit.hidden)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please tap edit button to make any changes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    
    self.btnReccit.alpha = 1.0;
    self.btnNotReccit.alpha = 0.3;
}

- (IBAction)btnNoneReccitTouched:(id)sender
{
    if(!self.btnEdit.hidden)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please tap edit button to make any changes" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    self.btnReccit.alpha = 0.3;
    self.btnNotReccit.alpha = 1.0;
}

- (IBAction)btnShareTouched:(id)sender
{
    NSString *urlString = [NSString stringWithFormat:kRCAPIUpdateComment, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], self.location.ID, self.btnReccit.alpha == 1.0 ? @"yes" : @"no", self.rateView.rate, self.txtComment.text];
    NSLog(@"REQUEST URL: %@", urlString);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Start new request
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    [client postPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"review response: %@", rO);
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You reviewed sucessfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alerView show];
        
        [self btnCancelTouched:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    
    
    
   /* NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"review response: %@", rO);
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You reviewed sucessfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alerView show];
        
        [self btnCancelTouched:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [RCCommonUtils showMessageWithTitle:@"Error" andContent:@"Network error. Please try again later!"];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
    */
    
   
}

- (IBAction)btnEditTouched:(id)sender
{
    self.btnEdit.hidden = YES;
    self.btnShare.hidden = NO;
    self.btnCancel.hidden = NO;
    self.txtComment.editable = YES;
    self.rateView.editable = YES;
}


- (IBAction)btnCancelTouched:(id)sender
{
    self.btnEdit.hidden = NO;
    self.btnShare.hidden = YES;
    self.btnCancel.hidden = YES;
    self.txtComment.editable = NO;
    self.rateView.editable = NO;
}

- (IBAction)btnDoneTouched:(id)sender
{
    [self.txtComment resignFirstResponder];
}

#pragma mark -
#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.4 animations:^{
        self.view.frame = CGRectMake(0, -110, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.4 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

@end
