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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.imgAvatar setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserImageUrl]] placeholderImage:[UIImage imageNamed:@"ic_me2.png"]];
    
    [self.lbName setText:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserName]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
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

@end
