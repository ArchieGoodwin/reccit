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
#import "AFNetworking.h"
#import "RCDefine.h"
#import "NSManagedObject+NWCoreDataHelper.h"
#import "RCUser.h"
@implementation RCVibeHelper


-(RCConversation *)getConverationById:(NSInteger *)convId
{
    
    NSPredicate *predicate = [[NSPredicate alloc] init];
    predicate = [NSPredicate predicateWithFormat:@"placeId = %i", convId];
    RCConversation *obj = [RCConversation getSingleObjectByPredicate:predicate];
    
    
    return obj;
}


-(RCMessage *)getMessageById:(NSString *)messId
{
    
    NSPredicate *predicate = [[NSPredicate alloc] init];
    predicate = [NSPredicate predicateWithFormat:@"messageId = %@", messId];
    RCMessage *mess = [RCMessage getSingleObjectByPredicate:predicate];
    
    return mess;
}


-(RCUser *)getUserById:(NSInteger)userId
{
    
    NSPredicate *predicate = [[NSPredicate alloc] init];
    predicate = [NSPredicate predicateWithFormat:@"userId = %i", userId];
    RCUser *mess = [RCUser getSingleObjectByPredicate:predicate];
    
    return mess;
}

-(BOOL)createMessageFromDict:(NSDictionary *)dict conv:(RCConversation *)conv
{
    BOOL hasNew = NO;

    RCMessage *mess = [self getMessageById:[dict objectForKey:@"Id"]];
    if(mess == nil)
    {
        hasNew = YES;
        //create message
        
        RCMessage *message = [RCMessage createEntityInContext];
        
        NSString *dateStr = [dict objectForKey:@"CreateDt"];

        if([dateStr hasPrefix:@"\/Date("])
        {

            dateStr = [dateStr substringFromIndex:6];
            dateStr = [dateStr substringToIndex:13];
            NSLog(@"%@", dateStr);

        }
        NSLog(@"%f    - %@",[[dict objectForKey:@"CreateDt"] doubleValue],[NSDate dateWithTimeIntervalSince1970:([dateStr doubleValue] /1000)]);
        message.messageDate = [NSDate dateWithTimeIntervalSince1970:([dateStr doubleValue] /1000)];

        message.messageId = [dict objectForKey:@"Id"];
        message.messageText = [dict objectForKey:@"Text"];
        message.conversationId = conv.conversationId;
        message.conversation = conv;
        
        RCUser *user = [self getUserById:[dict objectForKey:@"UserId"]];
        
        if(user == nil)
        {
            user = [RCUser createEntityInContext];
            user.userId = [NSNumber numberWithInt:[[dict objectForKey:@"UserId"] integerValue]];
        }
        
        message.user = user;
        
    }
    
    return hasNew;
}

-(BOOL)createConversationFromDict:(NSArray *)dict placeId:(NSInteger)placeId
{
    BOOL hasNew = NO;

    if(dict.count > 0)
    {
        
        RCConversation *conv = [self getConverationById:placeId];

        if(conv != nil)
        {
            //check messages
            for(NSDictionary *messDict in dict)
            {
                BOOL isNewMessage = [self createMessageFromDict:messDict conv:conv];
                if(isNewMessage)
                {
                    hasNew = YES;
                }
            }
        }
        else
        {
            //create conv
            hasNew = YES;
            
            RCConversation *conv = [RCConversation createEntityInContext];
            conv.placeId = [NSNumber numberWithInt:placeId];
            for(NSDictionary *messDict in dict)
            {
                [self createMessageFromDict:messDict conv:conv];
            }
        }

        
        [RCConversation saveDefaultContext];
        NSLog(@"conv.placeName = %@", conv.placeName);
        if(conv.placeName == nil)
        {
            [self getPlaceFromServer:placeId conv:conv completionBlock:^(BOOL result, NSError *error) {
                
            }];
        }

    }
    
    
    return hasNew;
    
}


-(void)getPlaceFromServer:(NSInteger)placeId  conv:(RCConversation *)conv completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    //Message/FetchByPlace?PlaceId=value
    
    NSString *urlString = [NSString stringWithFormat:@"http://recchat.incoding.biz/Place/Get/%i", placeId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get getPlaceFromServer url : %@", urlString);
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"getPlaceFromServer %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        if([rO objectForKey:@"data"] != [NSNull null])
        {
            if(conv != nil)
            {
                conv.placeName = [[rO objectForKey:@"data"] objectForKey:@"Name"];
                [RCConversation saveDefaultContext];
            }
            
            if(completionBlock)
            {
                completionBlock(YES, nil);
            }
        }

      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completionBlock)
        {
            completionBlock(NO, error);
        }
    }];
    
    [operation start];
}

-(void)getConversationFromServer:(NSInteger)placeId completionBlock:(RCCompleteBlockWithConvResult)completionBlock
{
    
    //Message/FetchByPlace?PlaceId=value
    
    NSString *urlString = [NSString stringWithFormat:@"http://recchat.incoding.biz/Message/FetchByPlace?PlaceId=%i", placeId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get getConversationFromServer url : %@", urlString);
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"getConversationFromServer %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        BOOL hasNew = NO;

        BOOL isNewConv = [self createConversationFromDict:[rO objectForKey:@"data"] placeId:placeId];
        if(isNewConv)
        {
            hasNew = YES;
        }

        RCConversation *conv = [self getConverationById:placeId];
        
        if(completionBlock)
        {
            completionBlock(conv, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
    
    [operation start];
}

-(void)getConversationsFormServer:(NSInteger)userId completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"http://recchat.incoding.biz/Message/FetchByUser?UserId=%@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get getConversationsFormServer url : %@", urlString);
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"getConversationsFormServer %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

        BOOL hasNew = NO;
        for(NSDictionary *convDict in [rO objectForKey:@"data"])
        {
            BOOL isNewConv = [self createConversationFromDict:[convDict objectForKey:@"Messages"] placeId:[[convDict objectForKey:@"PlaceId"] integerValue]];
            if(isNewConv)
            {
                hasNew = YES;
            }
        }
        
        
        if(completionBlock)
        {
            completionBlock(hasNew, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completionBlock)
        {
            completionBlock(NO, error);
        }
    }];
    
    [operation start];
}


-(NSMutableArray *)getBubblesFromConversation:(RCConversation *)conversation  myUserId:(NSInteger)myUserId
{
    NSMutableArray *temp = [NSMutableArray new];
    for(RCMessage *message in conversation.messages)
    {
        NSLog(@"%i   %i    %@", [message.user.userId integerValue], myUserId,  message.messageDate );
        if([message.user.userId integerValue] != myUserId)
        {
            NSBubbleData *someoneBubble = [NSBubbleData dataWithText:message.messageText date:message.messageDate == nil ? [NSDate date] : message.messageDate  type:BubbleTypeSomeoneElse];
            someoneBubble.avatarUrl = message.user.avatarUrl;
            [temp addObject:someoneBubble];
        }
        else
        {
            NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.messageText date:message.messageDate == nil ? [NSDate date] : message.messageDate  type:BubbleTypeMine];
            sayBubble.avatarUrl = message.user.avatarUrl;
            [temp addObject:sayBubble];
        }

    }
    
    return temp;
}

-(void)sendMessageFromUserId:(NSInteger)userId messageText:(NSString *)messageText placeId:(NSInteger)placeId subj:(NSString *)subj completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"http://recchat.incoding.biz/Message/Send"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get sendMessageFromUserId url : %@", urlString);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *arr = @{@"UserId":[NSNumber numberWithInt:userId],@"PlaceId":[NSNumber numberWithInt:placeId],@"Text":messageText,@"Subject":@""};
    [client setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [client postPath:@"" parameters:arr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"sendMessageFromUserId %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if(completionBlock)
        {
            completionBlock(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error sendMessageFromUserId %@", [error description]);
        
        completionBlock(NO, error);
    }];
    
}

-(void)addUserToPlaceTalk:(NSInteger)userId placeId:(NSInteger)placeId completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"http://recchat.incoding.biz/Participate/Add"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get addUserToPlaceTalk url : %@", urlString);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *arr = @{@"UserId":[NSNumber numberWithInt:userId],@"PlaceId":[NSNumber numberWithInt:placeId]};
    [client setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [client postPath:@"" parameters:arr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"addUserToPlaceTalk %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error addUserToPlaceTalk %@", [error description]);
        
        completionBlock(NO, error);
    }];
    
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
