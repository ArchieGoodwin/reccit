//
//  RCLinkedAccountsViewController.h
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "BZFoursquare.h"
#import "GAITrackedViewController.h"

@interface RCLinkedAccountsViewController : GAITrackedViewController <SA_OAuthTwitterControllerDelegate, BZFoursquareRequestDelegate, BZFoursquareSessionDelegate>
{
    SA_OAuthTwitterEngine *_engine;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@property (weak, nonatomic) IBOutlet UIButton *btnFacebookUpdate;
@property (weak, nonatomic) IBOutlet UIButton *btnFoursquareUpdate;
@property (weak, nonatomic) IBOutlet UIButton *btnTwitterUpdate;

@property (weak, nonatomic) IBOutlet UIImageView *imgFacebookConnect;
@property (weak, nonatomic) IBOutlet UIImageView *imgTwitterConnect;
@property (weak, nonatomic) IBOutlet UIImageView *imgFoursquareConnect;

@property(nonatomic, strong) BZFoursquare *foursquare;

@end
