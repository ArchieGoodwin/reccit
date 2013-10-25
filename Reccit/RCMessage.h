//
//  RCMessage.h
//  Reccit
//
//  Created by Nero Wolfe on 24/10/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RCConversation, RCUser;

@interface RCMessage : NSManagedObject

@property (nonatomic, retain) NSString * authorUserId;
@property (nonatomic, retain) NSString * conversationId;
@property (nonatomic, retain) NSDate * messageDate;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageText;
@property (nonatomic, retain) RCConversation *conversation;
@property (nonatomic, retain) RCUser *user;

@end
