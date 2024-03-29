//
//  RCConversation.h
//  Reccit
//
//  Created by Nero Wolfe on 24/10/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RCMessage;

@interface RCConversation : NSManagedObject

@property (nonatomic, retain) NSString * conversationId;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSString * messagesCount;
@property (nonatomic, retain) NSString * newMessagesCount;
@property (nonatomic, retain) NSNumber * placeId;
@property (nonatomic, retain) NSString * placeName;
@property (nonatomic, retain) NSSet *messages;
@end

@interface RCConversation (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(RCMessage *)value;
- (void)removeMessagesObject:(RCMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
