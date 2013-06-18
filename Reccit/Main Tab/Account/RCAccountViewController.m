//
//  RCAccountViewController.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCAccountViewController.h"
#import "RCDefine.h"
#import "UIImageView+WebCache.h"
#import "RCTermsViewController.h"
#import "RCAppDelegate.h"
@interface RCAccountViewController ()

@end

@implementation RCAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) sizeButtonToText:(UIButton *)button availableSize:(CGSize)availableSize padding:(UIEdgeInsets)padding {
    CGRect boundsForText = button.frame;
    
    // Measures string
    CGSize stringSize = [button.titleLabel.text sizeWithFont:button.titleLabel.font];
    stringSize.width = MIN(stringSize.width + padding.left + padding.right, availableSize.width);
    
    // Center's location of button
    boundsForText.origin.x += (boundsForText.size.width - stringSize.width) / 2;
    boundsForText.size.width = stringSize.width;
    [button setFrame:boundsForText];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] == nil)
    {
        [_btnVibe setTitle:@"Vibe Is Off" forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"vibe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //[_btnVibe sizeToFit];
        //[self sizeButtonToText:_btnVibe availableSize:_btnVibe.frame.size padding:UIEdgeInsetsZero];
        

    }
    else
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
        {
            [_btnVibe setTitle:@"Vibe Is On" forState:UIControlStateNormal];
            //[self sizeButtonToText:_btnVibe availableSize:_btnVibe.frame.size padding:UIEdgeInsetsZero];

            
        }
        else
        {
            [_btnVibe setTitle:@"Vibe Is Off" forState:UIControlStateNormal];
            
            //[self sizeButtonToText:_btnVibe availableSize:_btnVibe.frame.size padding:UIEdgeInsetsZero];

            
        }
    }
    
    
    
	// Do any additional setup after loading the view.
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.lbName setText:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserName]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}


-(void)reallyLogout
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCFirstTimeLogin];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCFacebookLoggedIn];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCTwitterLoggedIn];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserImageUrl];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserName];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserFacebookId];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCUserId];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kRCFoursquareLoggedIn];

    
    
    [[NSUserDefaults standardUserDefaults]  synchronize];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate resetWindowToInitialView];
}

- (IBAction)btnLogOut:(id)sender {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    
    
    
  
}
- (IBAction)btnVibeSwitch:(id)sender {
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] == nil)
    {
        [_btnVibe setTitle:@"Vibe Is On" forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"vibe"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    else
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
        {
            [_btnVibe setTitle:@"Vibe Is Off" forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"vibe"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }
        else
        {
            [_btnVibe setTitle:@"Vibe Is On" forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"vibe"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            
        }
        
    }
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self reallyLogout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushAbout"])
    {
        RCTermsViewController *terms = (RCTermsViewController *)segue.destinationViewController;
        
        terms.type = sender;
    }
}

#pragma mark -
#pragma mark - Button

- (IBAction)btnAboutTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushAbout" sender:@"about"];
}

- (IBAction)btnTermsTouched:(id)sender
{
    [self performSegueWithIdentifier:@"PushAbout" sender:@"terms"];
}

- (void)viewDidUnload {
    [self setBtnVibe:nil];
    [super viewDidUnload];
}
@end
