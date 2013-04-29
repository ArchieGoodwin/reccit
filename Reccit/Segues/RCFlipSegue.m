//
//  RCFlipSegue.m
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCFlipSegue.h"

@implementation RCFlipSegue

-(void)perform
{
    UIViewController *dst = [self destinationViewController];
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.5];
    [[[self sourceViewController] navigationController] pushViewController:dst animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[[self sourceViewController] navigationController].view cache:NO];
    [UIView commitAnimations];
}

@end
