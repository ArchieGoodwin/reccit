//
//  RCLoginTwitterViewController.h
//  Reccit
//
//  Created by Lee Way on 1/27/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SA_OAuthTwitterController.h"

@interface RCLoginTwitterViewController : UIViewController <SA_OAuthTwitterControllerDelegate>
{
    SA_OAuthTwitterEngine *_engine;
}

@end
