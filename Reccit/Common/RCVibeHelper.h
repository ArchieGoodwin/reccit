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


-(NSMutableArray *)getBubblesFromConversation:(RCConversation *)conversation  myUserId:(NSInteger)myUserId;
-(void)getConversationsFormServer:(NSInteger)userId completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(void)addUserToPlaceTalk:(NSInteger)userId placeId:(NSInteger)placeId completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(void)getConversationFromServer:(NSInteger)placeId completionBlock:(RCCompleteBlockWithConvResult)completionBlock;
-(void)sendMessageFromUserId:(NSInteger)userId messageText:(NSString *)messageText placeId:(NSInteger)placeId subj:(NSString *)subj completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(RCConversation *)getConverationById:(NSInteger *)convId;
-(void)getPlaceFromServer:(NSInteger)placeId  conv:(RCConversation *)conv completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(void)getUserFromServer:(NSInteger)userId  mess:(RCMessage *)mess completionBlock:(RCCompleteBlockWithMessageResult)completionBlock;
-(void)registerUser:(NSInteger)userId deviceToken:(NSString *)deviceToken completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(NSArray *)getAllConversationsSortedByDate;
@end
