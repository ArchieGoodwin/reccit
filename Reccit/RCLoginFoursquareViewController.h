//
//  RCLoginFoursquareViewController.h
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"

@interface RCLoginFoursquareViewController : UIViewController <BZFoursquareRequestDelegate, BZFoursquareSessionDelegate>

@property(nonatomic, strong) BZFoursquare *foursquare;

@end
