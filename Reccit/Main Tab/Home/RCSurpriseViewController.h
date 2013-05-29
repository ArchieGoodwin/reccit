//
//  RCSurpriseViewController.h
//  Reccit
//
//  Created by Lee Way on 1/31/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCSurpriseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbResult;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@property (weak, nonatomic) IBOutlet UIImageView *imgHappyHour;

@property (strong, nonatomic) NSMutableArray *listLocation;

@property (strong, nonatomic) NSString *querySearch;

@property (assign) BOOL isHappyHour;

@end
