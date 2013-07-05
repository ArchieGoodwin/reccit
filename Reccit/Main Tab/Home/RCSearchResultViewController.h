//
//  RCSearchResultViewController.h
//  Reccit
//
//  Created by Lee Way on 1/31/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface RCSearchResultViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *c1;
@property (weak, nonatomic) IBOutlet UIImageView *c2;
@property (weak, nonatomic) IBOutlet UITextField *c3;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (strong, nonatomic) IBOutlet NSString *tfLocation;
@property (weak, nonatomic) IBOutlet UIImageView *imgSurprise;
@property (weak, nonatomic) IBOutlet UITableView *tbResult;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberOfReccits;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberOfFriends;
@property (strong, nonatomic) NSString *categoryName;

@property (strong, nonatomic) NSMutableArray *listLocationReccit;
@property (strong, nonatomic) NSMutableArray *listLocationFriend;
@property (strong, nonatomic) NSMutableArray *listLocationPopular;
@property (assign, nonatomic) BOOL isSurprase;
@property (assign, nonatomic) BOOL showTabs;
@property (assign, nonatomic) BOOL isSearch;
@property (assign) NSInteger currentTab;
@property (weak, nonatomic) IBOutlet UIButton *btnSearchInside;
@property (nonatomic, strong) NSString *category;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;

@property (strong, nonatomic) NSString *querySearch;
@property (strong, nonatomic) NSString *searchString;

@end
