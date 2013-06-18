//
//  RCAccountViewController.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCAccountViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbName;

- (IBAction)btnAboutTouched:(id)sender;
- (IBAction)btnTermsTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnVibe;

@end
