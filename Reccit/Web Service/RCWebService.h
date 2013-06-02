//
//  RCWebService.h
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "RCDefine.h"
@interface RCWebService : NSObject
{
    

}
+ (void)authenticateFacebookWithToken:(NSString *)token userId:(NSString *)userId;
+ (void)authenticateTwitterWithToken:(NSString *)token userId:(NSString *)userId;
+ (void)authenticateFoursquareWithToken:(NSString *)token userId:(NSString *)userId;
@end
