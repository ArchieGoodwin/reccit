//
//  RCRateViewController.h
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "DYRateView.h"
#import "MBProgressHUD.h"
#import "RCBaseViewController.h"
#import "RCReviewLocationViewController.h"

@interface RCRateViewController : RCBaseViewController <UITableViewDataSource, UITableViewDelegate, DYRateViewDelegate> 

@property (strong, nonatomic) NSMutableArray *listLocation;
@property (strong, nonatomic) ASIHTTPRequest *request;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) RCReviewLocationViewController *reviewVc;

@property (weak, nonatomic) IBOutlet UITableView *tbLocation;
- (void)callAPIGetListLocationRate;
@end
