//
//  RCConversationsViewController.h
//  Reccit
//
//  Created by Nero Wolfe on 6/16/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCConversationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *conversations;
@end
