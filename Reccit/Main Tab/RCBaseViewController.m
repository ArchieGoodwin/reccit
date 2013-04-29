//
//  RCBaseViewController.m
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCBaseViewController.h"

@interface RCBaseViewController ()

@end

@implementation RCBaseViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Presetation custom

- (void) presentSemiModalViewController:(RCBaseViewController*)vc {
	UIView* modalView = vc.view;
	UIView* cvView = vc.coverView;
    UIView *rootView = UIApplication.sharedApplication.delegate.window.rootViewController.view;
    
	cvView.frame = rootView.bounds;
    cvView.alpha = 0.0f;
    
    modalView.frame = rootView.bounds;
	modalView.center = self.offscreenCenter;
	
	[rootView addSubview:cvView];
	[rootView addSubview:modalView];
	
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	
	modalView.frame = CGRectMake(0, 0, modalView.frame.size.width, modalView.frame.size.height);
	cvView.alpha = 0.7;
    
	[UIView commitAnimations];
    
}

-(void) dismissSemiModalViewController:(RCBaseViewController*)vc {
	double animationDelay = 0.4;
	UIView* modalView = vc.view;
	UIView* cvView = vc.coverView;
    
    
	[UIView beginAnimations:nil context:(__bridge void *)(modalView)];
	[UIView setAnimationDuration:animationDelay];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dismissSemiModalViewControllerEnded:finished:context:)];
	
    modalView.center = self.offscreenCenter;
	cvView.alpha = 0.0f;
    
	[UIView commitAnimations];
    
	[cvView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:animationDelay];
}

- (void) dismissSemiModalViewControllerEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	UIView* modalView = (__bridge UIView*)context;
	[modalView removeFromSuperview];
}

-(CGPoint) offscreenCenter {
    CGPoint offScreenCenter = CGPointZero;
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGSize offSize = UIScreen.mainScreen.bounds.size;
    
	if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		offScreenCenter = CGPointMake(offSize.height / 2.0, -offSize.width * 0.5);
	} else {
		offScreenCenter = CGPointMake(offSize.width / 2.0, -offSize.height * 0.5);
	}
    
    return offScreenCenter;
}


@end
