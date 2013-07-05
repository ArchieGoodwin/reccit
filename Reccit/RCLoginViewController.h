//
//  RCLoginViewController.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SA_OAuthTwitterController.h"
#import "GAITrackedViewController.h"





@class SA_OAuthTwitterEngine;

@interface RCLoginViewController : GAITrackedViewController <SA_OAuthTwitterControllerDelegate>
{
    SA_OAuthTwitterEngine *_engine;
}

@end
