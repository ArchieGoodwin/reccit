//
//  RCReviewLocationViewController.h
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCLocation.h"
#import "DYRateView.h"
#import "RCBaseViewController.h"
#import "ASIHTTPRequest.h"

@interface RCReviewLocationViewController : RCBaseViewController <UITextViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) RCLocation *location;
@property (weak, nonatomic) IBOutlet UIView *viewRound;

@property (strong, nonatomic) RCBaseViewController *vsParrent;

@property (weak, nonatomic) IBOutlet DYRateView *rateView;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnUnLike;

@property (weak, nonatomic) IBOutlet UITextView *tvReview;

@property (strong, nonatomic) ASIHTTPRequest *request;
@property (nonatomic, assign) BOOL shouldSendImmediately;
@property (assign) BOOL recommendation;

@end
