//
//  RCMessage.h
//  Reccit
//
//  Created by Nero Wolfe on 6/15/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RCUser.h"
#import "RCConversation.h"
@interface RCMessage : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageText;
@property (nonatomic, retain) NSNumber * authorUserId;
@property (nonatomic, retain) NSString * conversationId;
@property (nonatomic, retain) NSDate * messageDate;
@property (nonatomic, retain) RCConversation *conversation;
@property (nonatomic, retain) RCUser *user;

@end
