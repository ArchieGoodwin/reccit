//
//  RCVibeHelper.h
//  Reccit
//
//  Created by Nero Wolfe on 6/15/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDefine.h"
@class RCConversation;
@class RCMessage;
@interface RCVibeHelper : NSObject


+(RCVibeHelper *)sharedInstance;


@property (nonatomic, strong) NSMutableArray *conversations;


-(NSMutableArray *)getBubblesFromConversation:(RCConversation *)conversation  myUserId:(NSString *)myUserId;
-(void)getConversationsFormServer:(NSString *)userId completionBlock:(RCCompleteBlockWithIntResult)completionBlock;
-(void)addUserToPlaceTalk:(NSString *)userId placeId:(NSInteger)placeId completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(void)getConversationFromServer:(NSInteger)placeId completionBlock:(RCCompleteBlockWithConvResult)completionBlock;
-(void)sendMessageFromUserId:(NSString *)userId messageText:(NSString *)messageText placeId:(NSInteger)placeId subj:(NSString *)subj completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(RCConversation *)getConverationById:(NSInteger *)convId;
-(void)getPlaceFromServer:(NSInteger)placeId  conv:(RCConversation *)conv completionBlock:(RCCompleteBlockWithStringResult)completionBlock;
-(void)getUserFromServer:(NSString *)userId  messId:(NSString *)messId completionBlock:(RCCompleteBlockWithMessageIdResult)completionBlock;
-(void)registerUser:(NSString *)userId deviceToken:(NSString *)deviceToken completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(NSArray *)getAllConversationsSortedByDate;
-(void)removeUserFromPlaceTalk:(NSString *)userId placeId:(NSInteger)placeId completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(NSArray *)getMessagesSorted:(RCConversation *)conversation;
-(void)clearConversations;
- (NSDate *)dateToGMT:(NSDate *)sourceDate;
-(NSDate *)dateOfLastMessage:(RCConversation *)conv;
-(RCMessage *)getMessageById:(NSString *)messId;
@end
