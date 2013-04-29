//
//  RCRateCell.h
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYRateView.h"

@interface RCRateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbAddress;
@property (weak, nonatomic) IBOutlet DYRateView *rateView;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnUnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnReview;

@end
