//
//  RCWebViewController.h
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imgAvatar;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *url;

@end
