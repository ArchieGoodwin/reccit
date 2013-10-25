//
//  RCUser.h
//  Reccit
//
//  Created by Nero Wolfe on 24/10/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RCMessage;

@interface RCUser : NSManagedObject

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *messages;
@end

@interface RCUser (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(RCMessage *)value;
- (void)removeMessagesObject:(RCMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
