//
//  RCMainTabbarController.m
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCMainTabbarController.h"
#import "RCAppDelegate.h"
#import "RCVibeHelper.h"
@interface RCMainTabbarController ()
{
    RCConversationsViewController *contr;
    UINavigationController *nav;
}
@end

@implementation RCMainTabbarController

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
    

    

    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate showButtonForMessages];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessagesCount:) name:@"vibes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showConv) name:@"showvibes" object:nil];

    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil)
    {
        [[RCVibeHelper sharedInstance] registerUser:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId] deviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] completionBlock:^(BOOL result, NSError *error) {
            
            NSLog(@"success registerUser");
            
            [appDelegate getVibes];

            
        }];
    }
    //else
    //{
    //    [appDelegate getVibes];

    //}
    
    

	// Do any additional setup after loading the view.
    self.btnTab1.selected = YES;
    
    self.viewButton.frame = CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50);
    [self.tabBar setHidden:YES];
    [self.view addSubview:self.viewButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    

    
    //[appDelegate showButtonForMessages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showMessagesCount:(NSNotification *)notification
{
    int messages = [((NSNumber *) [notification object]) integerValue];

    NSLog(@"%i", messages);
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showNewMessages:notification];
}

-(void)dismissMe
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)showConv
{
    contr = [[RCConversationsViewController alloc] initWithNibName:@"RCConversationsViewController" bundle:nil];
    
    nav = [[UINavigationController alloc] initWithRootViewController:contr];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark -
#pragma mark - Button touched

- (IBAction)btnTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"%i", btn.tag);
    self.btnTab1.selected = NO;
    self.btnTab2.selected = NO;
    self.btnTab3.selected = NO;
    self.btnTab4.selected = NO;
    
    btn.selected = YES;
    [self setSelectedIndex:btn.tag-1001];
    
    if(btn.tag == 1001)
    {
        [((UINavigationController *)self.selectedViewController) popToRootViewControllerAnimated:YES];
    }
    
}

@end
