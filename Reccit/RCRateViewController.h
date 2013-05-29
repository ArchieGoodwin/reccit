//
//  RCRateViewController.h
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import "MBProgressHUD.h"
#import "RCBaseViewController.h"
#import "RCReviewInDetailsViewController.h"

@interface RCRateViewController : RCBaseViewController <UITableViewDataSource, UITableViewDelegate, DYRateViewDelegate> 

@property (strong, nonatomic) NSMutableArray *listLocation;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) RCReviewInDetailsViewController *reviewVc;

@property (weak, nonatomic) IBOutlet UITableView *tbLocation;
- (void)callAPIGetListLocationRate;
@end
