//
//  MainViewController.m
//  DRDynamicSlideShow
//
//  Created by David Román Aguirre on 17/09/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "SlideVC.h"
#import "RCAppDelegate.h"
#import "UIColor+RGBA.h"
#import "RCCommonUtils.h"
#define LOGS_ENABLED NO

@implementation SlideVC

- (id)init {
    if (self = [super init]) {
        self.navigationBar = [UINavigationBar new];
        self.slideShow = [DRDynamicSlideShow new];
        self.viewsForPages = [NSArray new];
    }
    
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    RCAppDelegate *appDelegate =  (RCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideConversationButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [self prefersStatusBarHidden];
        //[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        
        //}];
        
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        CGRect frame = self.view.frame;
        frame.origin.y = frame.origin.y - 20;
        frame.size.height  =frame.size.height + 20;
        self.view.frame = frame;
        
        
    }
    
    #pragma mark View
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer setCornerRadius:4.5];
    [self.view.layer setMasksToBounds:YES];
    
    
    #pragma mark DRDynamicSlideShow
    
    [self.slideShow setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.slideShow setContentInset:UIEdgeInsetsMake(self.navigationBar.frame.size.height/2, 0, 0, 0)];
    [self.slideShow setAlpha:0];
    
    [self.slideShow setDidReachPageBlock:^(NSInteger reachedPage) {
        NSLog(@"Current Page: %li", (long)reachedPage);
        
        /*UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"Popup-Icon-X.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(2, 2, 25, 25);
        
        [self.view addSubview:btn];*/
        
        if(reachedPage == 9)
        {
            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn1 addTarget:self action:@selector(closeMe) forControlEvents:UIControlEventTouchUpInside];
            btn1.frame = self.view.frame;
            [self.view addSubview:btn1];
        }
        
        
    }];
    
    [self.view insertSubview:self.slideShow belowSubview:self.navigationBar];
    
    #pragma mark DRDynamicSlideShow Subviews
    
    
    [self setupSlideShowSubviewsAndAnimations];
    
    
    
}


-(void)closeMe
{
   
    
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        
        CGRect frame = self.view.frame;
        frame.origin.y = frame.origin.y + 20;
        frame.size.height  = frame.size.height - 20;
        self.view.frame = frame;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

        
        
    }
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
}


- (void)setupSlideShowSubviewsAndAnimations {
    
    
    for (int i = 1; i < 11; i++) {
        CGFloat verticalOrigin = self.view.frame.size.height/2-self.view.frame.size.height/2;

        UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, verticalOrigin+self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
        
        
        
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:[RCCommonUtils isIphone5] ? @"Tour%i.jpg" : @"Page%i.jpg", i]]];
        imgView.frame = view.frame;
        
        
        [view addSubview:imgView];
        self.slideShow.vc = self;
        [self.slideShow addSubview:view onPage:(i - 1)];
        [self.slideShow addAnimation:[DRDynamicSlideShowAnimation animationForSubview:imgView page:(i-1) keyPath:@"alpha" toValue:@0 delay:0]];

    }
   
    
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.slideShow setAlpha:1];
    } completion:nil];
}

@end