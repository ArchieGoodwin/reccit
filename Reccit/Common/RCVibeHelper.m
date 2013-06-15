//
//  RCVibeHelper.m
//  Reccit
//
//  Created by Nero Wolfe on 6/15/13.
//  Copyright (c) 2013 Incoding. All rights reserved.
//

#import "RCVibeHelper.h"
#import "NSBubbleData.h"
#import "RCMessage.h"
#import "RCUser.h"
#import "RCConversation.h"
@implementation RCVibeHelper






-(NSMutableArray *)getBubblesFromConversation:(RCConversation *)conversation  myUserId:(NSInteger)myUserId
{
    NSMutableArray *temp = [NSMutableArray new];
    for(RCMessage *message in conversation.messages)
    {
        if([message.user.userId integerValue] != myUserId)
        {
            NSBubbleData *someoneBubble = [NSBubbleData dataWithText:message.messageText date:message.messageDate  type:BubbleTypeSomeoneElse];
            someoneBubble.avatarUrl = message.user.avatarUrl;
            [temp addObject:someoneBubble];
        }
        else
        {
            NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.messageText date:message.messageDate  type:BubbleTypeMine];
            sayBubble.avatarUrl = message.user.avatarUrl;
            [temp addObject:sayBubble];
        }

    }
    
    return temp;
}








- (id)init {
    self = [super init];
    
    
   
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    
#else
    
    
#endif
    
    return self;
    
}



+(id)sharedInstance
{
    static dispatch_once_t pred;
    static RCVibeHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RCVibeHelper alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    
    abort();
}
@end
