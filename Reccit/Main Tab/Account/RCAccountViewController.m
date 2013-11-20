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
#import "SlideVC.h"
@interface RCAccountViewController ()
{
    UITapGestureRecognizer *vibeGesture;
}
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
- (IBAction)btnShowTutorial:(id)sender {
    
    SlideVC *vc = [SlideVC new];
    [self presentViewController:vc animated:YES completion:^{
       
    }];
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

-(void)showHideVibe
{
    if(_btnVibe.hidden)
    {
        _btnVibe.hidden = NO;
        _btnVibe1.hidden = NO;
        [self changeStateOFVibeButton];

    }
    else
    {
        [_btnVibe setTitle:@"Vibe Is Off" forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"vibe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _btnVibe.hidden = YES;
        _btnVibe1.hidden = YES;

    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    
    vibeGesture = [UITapGestureRecognizer new];
    vibeGesture.numberOfTapsRequired = 3;
    [vibeGesture addTarget:self action:@selector(showHideVibe)];
    //[self.view addGestureRecognizer:vibeGesture];
    
    //_btnVibe.hidden = YES;
    //_btnVibe1.hidden = YES;
    //[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"vibe"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
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
	// Do any additional setup after loading the view.
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.lbName setText:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserName]];
}

-(void)changeStateOFVibeButton
{
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
        _btnVibe.hidden = NO;
        _btnVibe1.hidden = NO;
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
        {
            [_btnVibe setTitle:@"Vibe Is On" forState:UIControlStateNormal];
            //[self sizeButtonToText:_btnVibe availableSize:_btnVibe.frame.size padding:UIEdgeInsetsZero];
            //[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"vibe"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        else
        {
            [_btnVibe setTitle:@"Vibe Is Off" forState:UIControlStateNormal];
            //[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"vibe"];
            //[[NSUserDefaults standardUserDefaults] synchronize];
            //[self sizeButtonToText:_btnVibe availableSize:_btnVibe.frame.size padding:UIEdgeInsetsZero];
            
            
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
    {
        /* _btnVibe.hidden = NO;
        if(!_btnVibe.hidden)
        {
            [self changeStateOFVibeButton];
        }*/
    }
   
    
    
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

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fcheckin"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastDate"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"vibe"];

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

            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
            
             RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate hideConversationButton];
            
        }
        else
        {
            [_btnVibe setTitle:@"Vibe Is On" forState:UIControlStateNormal];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"vibe"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"vibe"] isEqualToString:@"YES"])
            {
                NSLog(@"Registering for push notifications...");
                [[UIApplication sharedApplication]
                 registerForRemoteNotificationTypes:
                 (UIRemoteNotificationTypeAlert |
                  UIRemoteNotificationTypeBadge |
                  UIRemoteNotificationTypeSound)];
            }
            
            RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showButtonForMessages];
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
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hideConversationButton];
    
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
    [self setBackImage:nil];
    [self setBtnVibe1:nil];
    [self setContainer:nil];
    [super viewDidUnload];
}
@end
