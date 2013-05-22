//
//  RCBaseViewController.h
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
@interface RCBaseViewController : GAITrackedViewController

@property (nonatomic, strong) UIView *coverView;

- (void) presentSemiModalViewController:(RCBaseViewController*)vc;
- (void) dismissSemiModalViewController:(RCBaseViewController*)vc;
- (void) dismissSemiModalViewControllerEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end
