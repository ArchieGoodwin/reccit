//
//  RCLocationDetailViewController.h
//  Reccit
//
//  Created by Lee Way on 1/31/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import <MapKit/MapKit.h>
#import "RCLocation.h"
#import "ASIHTTPRequest.h"
#import "RCBaseViewController.h"

@class RCReviewInDetailsViewController;
@interface RCLocationDetailViewController : RCBaseViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbPrice;
@property (weak, nonatomic) IBOutlet UILabel *lbCity;

@property (weak, nonatomic) IBOutlet UILabel *lbNoReview;
@property (weak, nonatomic) IBOutlet UIImageView *lbReviews;

@property (weak, nonatomic) IBOutlet UIButton *btnCall;

@property (weak, nonatomic) IBOutlet DYRateView *rateView;

@property (weak, nonatomic) IBOutlet UITableView *tbReview;

@property (strong, nonatomic) RCLocation *location;
@property (strong, nonatomic) ASIHTTPRequest *request;
@property (strong, nonatomic) NSMutableArray *listComment;

@property (strong, nonatomic) RCReviewInDetailsViewController *reviewVc;

@end
