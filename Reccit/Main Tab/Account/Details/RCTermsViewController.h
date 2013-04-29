//
//  RCTermsViewController.h
//  Reccit
//
//  Created by Lee Way on 2/2/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCTermsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *lbTitle;

@property (strong, nonatomic) NSString *type;

- (IBAction)btnBackTouched:(id)sender;

@end
