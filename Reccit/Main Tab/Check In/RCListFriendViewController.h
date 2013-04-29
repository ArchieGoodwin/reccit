//
//  RCListFriendViewController.h
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@class RCAddPlaceViewController;
@interface RCListFriendViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbFriends;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (strong, nonatomic) NSMutableArray *listFriends;
@property (strong, nonatomic) NSMutableArray *listFriendsFilter;

@property (strong, nonatomic) ASIHTTPRequest *request;

@property (strong, nonatomic) RCAddPlaceViewController *fatherVc;

@end
