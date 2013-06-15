//
//  RCVibeHelper.h
//  Reccit
//
//  Created by Nero Wolfe on 6/15/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RCConversation;
@interface RCVibeHelper : NSObject


+(RCVibeHelper *)sharedInstance;


@property (nonatomic, strong) NSMutableArray *conversations;


-(NSMutableArray *)getBubblesFromConversation:(RCConversation *)conversation  myUserId:(NSInteger)myUserId;

@end
