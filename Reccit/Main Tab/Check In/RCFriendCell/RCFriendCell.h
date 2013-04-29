//
//  RCFriendCell.h
//  Reccit
//
//  Created by Lee Way on 2/3/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIImageView *imgSource;
@property (weak, nonatomic) IBOutlet UIImageView *imgAva;
@property (weak, nonatomic) IBOutlet UIButton *checkBox;

@end
