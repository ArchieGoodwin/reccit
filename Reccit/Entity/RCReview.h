//
//  RCReview.h
//  Reccit
//
//  Created by Lee Way on 2/1/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPerson.h"

@interface RCReview : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, assign) BOOL isMark;

@property (nonatomic, assign) RCFriendSource source;

@end
