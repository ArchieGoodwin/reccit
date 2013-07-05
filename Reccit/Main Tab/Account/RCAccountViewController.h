//
//  RCAccountViewController.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface RCAccountViewController : GAITrackedViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbName;

@property (weak, nonatomic) IBOutlet UIButton *btnVibe1;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
- (IBAction)btnAboutTouched:(id)sender;
- (IBAction)btnTermsTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnVibe;
@property (strong, nonatomic) IBOutlet UIView *container;

@end
