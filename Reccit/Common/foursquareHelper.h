//
//  foursquareHelper.h
//  Reccit
//
//  Created by Nero Wolfe on 5/3/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDefine.h"

@interface foursquareHelper : NSObject


@property (nonatomic, strong) NSMutableArray *checkins;
@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) NSString *stringUserCheckins;

+(id)sharedInstance;
-(void)getCheckins:(NSString *)token completionBlock:(RCCompleteBlockWithResult)completionBlock;
@end
