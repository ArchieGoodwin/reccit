//
//  RCTermsViewController.m
//  Reccit
//
//  Created by Lee Way on 2/2/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCTermsViewController.h"
#import "RCDefine.h"
#import "UIImageView+WebCache.h"

@interface RCTermsViewController ()

@end

@implementation RCTermsViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"tos" ofType:@"html" inDirectory:nil];

    if ([self.type isEqualToString:@"about"])
    {
        [self.lbTitle setImage:[UIImage imageNamed:@"txt-about.png"] forState:UIControlStateNormal];
        htmlFile = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html" inDirectory:nil];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlFile]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Button

- (IBAction)btnBackTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
