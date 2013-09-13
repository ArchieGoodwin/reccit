//
//  RCAddPlaceViewController.h
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"
#import <MapKit/MapKit.h>
#import "SA_OAuthTwitterController.h"
#import "RCReviewInDetailsViewController.h"
#import "RCBaseViewController.h"
#import "MGTwitterEngine.h"
#import "RCWhereAmIViewController.h"
@class RCLocation;
@interface RCAddPlaceViewController : RCBaseViewController <UITextViewDelegate,SA_OAuthTwitterControllerDelegate , MGTwitterEngineDelegate, MKMapViewDelegate>
{
    SA_OAuthTwitterEngine *_engine;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgLike;
@property (weak, nonatomic) IBOutlet UILabel *lblReccits;

@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) RCLocation *location;

@property (strong, nonatomic) RCReviewInDetailsViewController *reviewVc;
@property (strong, nonatomic) RCWhereAmIViewController *messageVc;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *downView;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet DYRateView *rateView;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnUnLike;

@property (weak, nonatomic) IBOutlet UIImageView *imgLocation;

@property (weak, nonatomic) IBOutlet UISwitch *swFacebook;
@property (weak, nonatomic) IBOutlet UISwitch *swTwitter;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (strong, nonatomic) NSMutableArray *listFriends;

@property (weak, nonatomic) IBOutlet UILabel *lbCity;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (strong, nonatomic) NSString *reviewString;
@property (strong, nonatomic) NSString *messageString;

@property (assign, nonatomic) BOOL isAddNew;


@end
