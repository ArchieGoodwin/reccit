//
//  RCDirectViewController.h
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCLocation.h"
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"
#import "MapView.h"

@interface RCDirectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) RCLocation *location;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbStart;
@property (weak, nonatomic) IBOutlet UILabel *lbEnd;
@property (strong, nonatomic) NSMutableArray *instructions;
@property (weak, nonatomic) IBOutlet MapView *mapView;
@property (nonatomic, assign) NSInteger mode;
@property (strong, nonatomic) MapView *mainMap;

@end
