//
//  RCCheckInViewController.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"
#import <FacebookSDK/FacebookSDK.h>

@interface RCCheckInViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tbLocation;

@property (strong, nonatomic) NSMutableArray *listLocation;
@property (strong, nonatomic) NSMutableArray *listAnnotation;
@property (strong, nonatomic) ASIHTTPRequest *request;

@end
