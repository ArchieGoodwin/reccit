//
//  RCMyReviewViewController.h
//  Reccit
//
//  Created by Lee Way on 2/15/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCLocation.h"
#import "DYRateView.h"
#import "GAITrackedViewController.h"

@interface RCMyReviewViewController : GAITrackedViewController <UITextViewDelegate>

@property (nonatomic, strong) RCLocation *location;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIButton *btnReccit;
@property (weak, nonatomic) IBOutlet UIButton *btnNotReccit;
@property (weak, nonatomic) IBOutlet DYRateView *rateView;
@property (weak, nonatomic) IBOutlet UITextView *txtComment;

@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;


@end
