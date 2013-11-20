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
#import "NSDate-Utilities.h"

//#define VibePath @"http://recchat.incoding.biz/"
#define VibePath @"http://vibe.reccit.com/"
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

-(NSArray *)getMessagesSorted:(RCConversation *)conversation
{
     NSArray *array = [conversation.messages allObjects];
    
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"" ascending:NO comparator:^NSComparisonResult(RCMessage *obj1, RCMessage * obj2) {
        
        return [obj1.messageDate compare:obj2.messageDate];
    }];
    
    NSArray *result = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    
    return result;
}


-(NSArray *)getAllConversationsSortedByDate
{
    
    NSMutableArray *array = [RCConversation getAllRecords];

    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"" ascending:NO comparator:^NSComparisonResult(RCConversation *obj1, RCConversation * obj2) {

        if([self getMessagesSorted:obj1].count > 0 && [self getMessagesSorted:obj2].count > 0)
        {
            RCMessage *last1 = [self getMessagesSorted:obj1][0];
            RCMessage *last2 = [self getMessagesSorted:obj2][0];
            
            return [last1.messageDate compare:last2.messageDate];
        }
        return NSOrderedSame;
    }];
    
    NSArray *result = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    NSMutableArray *temp = [NSMutableArray new];
   
    for(RCConversation *conv in result)
    {

        
        if(conv.messages.count == 0)
        {
            [RCConversation deleteInContext:conv];
        }
        else
        {
            [temp addObject:conv];
        }
    }

    
    [RCConversation saveDefaultContext];
    
    
    return [temp copy];
}

-(RCUser *)getUserById:(NSString *)userId
{
    
    NSPredicate *predicate = [[NSPredicate alloc] init];
    predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
    RCUser *mess = [RCUser getSingleObjectByPredicate:predicate];
    
    return mess;
}

-(int)createMessageFromDict:(NSDictionary *)dict conv:(RCConversation *)conv
{
   int hasNew = 0;

    RCMessage *mess = [self getMessageById:[dict objectForKey:@"Id"]];
    if(mess == nil)
    {
        hasNew = 1;
        //create message
        if([dict objectForKey:@"Text"] != [NSNull null])
        {
            RCMessage *message = [RCMessage createEntityInContext];
            
            NSString *dateStr = [dict objectForKey:@"CreateDt"];
            
            if([dateStr hasPrefix:@"\/Date("])
            {
                
                dateStr = [dateStr substringFromIndex:6];
                dateStr = [dateStr substringToIndex:13];
                NSLog(@"%@", dateStr);
                
            }
            NSLog(@"%@    - %@",[dict objectForKey:@"CreateDt"],[NSDate dateWithTimeIntervalSince1970:([dateStr doubleValue] /1000)]);
            message.messageDate = [NSDate dateWithTimeIntervalSince1970:([dateStr doubleValue] /1000)];
            
            message.messageId = [dict objectForKey:@"Id"];
            message.messageText = [dict objectForKey:@"Text"];
            message.conversationId = conv.conversationId;
            message.conversation = conv;
            
            RCUser *user = [self getUserById:[dict objectForKey:@"UserId"]];
            
            if(user == nil)
            {
                user = [RCUser createEntityInContext];
                user.userId = [dict objectForKey:@"UserId"];
            }
            
            message.user = user;
        }
        else
        {
            hasNew = 0;
        }
        
        
    }
    
    return hasNew;
}


-(NSInteger)getNewMessagesFromConversationFromDate:(NSDate *)date conv:(RCConversation *)conv
{
    if(conv.lastDate != nil)
    {
        NSInteger i = 0;
        for(RCMessage *mess in [self getMessagesSorted:conv])
        {
            if([mess.messageDate isLaterThanDate:date])
            {
                i++;
            }
        }
        
        return i;
    }
    return conv.messages.count;
}


-(void)clearConversations
{
    NSMutableArray *converations = [RCConversation getAllRecords];
    for(RCConversation *conv in converations)
    {
        if([self getNewMessagesFromConversationFromDate:conv.lastDate conv:conv] == 0)
        {
            [RCConversation deleteInContext:conv];
        }
    }
    [RCConversation saveDefaultContext];
}


- (NSDate *)dateToGMT:(NSDate *)sourceDate {
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:destinationGMTOffset sinceDate:sourceDate];
    return destinationDate;
}


-(int)createConversationFromDict:(NSArray *)dict placeId:(NSInteger)placeId
{
    int hasNew = 0;

    if(dict.count > 0)
    {
        
        RCConversation *conv = [self getConverationById:placeId];

        if(conv != nil)
        {
            for(RCMessage *mess in conv.messages)
            {
                
                [RCMessage deleteInContext:mess];

            }
            int newMessages = 0;
            for(NSDictionary *messDict in dict)
            {
                int isNewMessage = [self createMessageFromDict:messDict conv:conv];
                newMessages = newMessages + isNewMessage;
                
            }
            
            hasNew = newMessages;
            if(conv.lastDate == nil)
            {
                conv.lastDate = [self dateOfLastMessage:conv];
                conv.messagesCount = [NSString stringWithFormat:@"%i", conv.messages.count];
            }
            else
            {
                conv.messagesCount = [NSString stringWithFormat:@"%i", [self getNewMessagesFromConversationFromDate:conv.lastDate conv:conv]];
                //conv.lastDate = [NSDate date];

            }
            NSLog(@"lastDate %@ conv.messagesCount = %@", conv.lastDate, conv.messagesCount);

            return conv.messagesCount.integerValue;
        }
        else
        {
            //create conv
            RCConversation *conv1 = [RCConversation createEntityInContext];
            conv1.placeId = [NSNumber numberWithInt:placeId];
            int newMessages = 0;

            for(NSDictionary *messDict in dict)
            {
                int isNewMessage = [self createMessageFromDict:messDict conv:conv1];
                newMessages = newMessages + isNewMessage;

            }
            hasNew = newMessages;
            conv1.messagesCount = [NSString stringWithFormat:@"%i", conv1.messages.count];
            conv1.lastDate = [self dateOfLastMessage:conv1];
            NSLog(@"lastDate %@ conv.messagesCount = %@", conv1.lastDate, conv1.messagesCount);
            return conv1.messagesCount.integerValue;


        }


    }
    
    return 0;
    
}


-(NSDate *)dateOfLastMessage:(RCConversation *)conv
{
    return ((RCMessage *)[self getMessagesSorted:conv].firstObject).messageDate;
}

-(void)getPlaceFromServer:(NSInteger)placeId  conv:(RCConversation *)conv completionBlock:(RCCompleteBlockWithStringResult)completionBlock
{
    //Message/FetchByPlace?PlaceId=value
    if(placeId != 0)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@Place/Get/%i", VibePath, placeId];
        
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
                    completionBlock([[rO objectForKey:@"data"] objectForKey:@"Name"], nil);
                }
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(completionBlock)
            {
                completionBlock(nil, error);
            }
        }];
        
        [operation start];
    }
   
}

-(void)getUserFromServer:(NSString *)userId  messId:(NSString *)messId completionBlock:(RCCompleteBlockWithMessageIdResult)completionBlock
{
    //Message/FetchByPlace?PlaceId=value
    
    NSString *urlString = [NSString stringWithFormat:@"%@User/Get/%@", VibePath, userId];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get getUserFromServer url : %@", urlString);
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"getUserFromServer %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        

        RCMessage *mess = [self getMessageById:messId];
        if(mess)
        {
            RCUser *user = [self getUserById:userId];
            
            if(user == nil)
            {
                user = [RCUser createEntityInContext];
                user.userId = userId;
                user.avatarUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",[NSString stringWithFormat:@"%@", userId]];
                if([rO objectForKey:@"data"] != [NSNull null])
                {
                    user.userName = [[rO objectForKey:@"data"] objectForKey:@"FirstName"];
                    
                }
                
                
                mess.user = user;
            }
            else
            {
                user.avatarUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",[NSString stringWithFormat:@"%@", userId]];
                if([rO objectForKey:@"data"] != [NSNull null])
                {
                    user.userName = [[rO objectForKey:@"data"] objectForKey:@"FirstName"];
                    
                }
                
            }
            if(completionBlock)
            {
                completionBlock(messId, nil);
            }
        }
        else
        {
            if(completionBlock)
            {
                completionBlock(nil, nil);
            }
        }
        

        
      
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
    
    [operation start];
}



-(void)getConversationFromServer:(NSInteger)placeId completionBlock:(RCCompleteBlockWithConvResult)completionBlock
{
    
    //Message/FetchByPlace?PlaceId=value
    
    NSString *urlString = [NSString stringWithFormat:@"%@Message/FetchByPlace?PlaceId=%i", VibePath, placeId];
    
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

-(void)getConversationsFormServer:(NSString *)userId completionBlock:(RCCompleteBlockWithIntResult)completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@Message/FetchByUser?UserId=%@", VibePath, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get getConversationsFormServer url : %@", urlString);
    
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"getConversationsFormServer %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

        int hasNew = 0;
        int i = 0;
        for(NSDictionary *convDict in [rO objectForKey:@"data"])
        {
            int isNewConv = [self createConversationFromDict:[convDict objectForKey:@"Messages"] placeId:[[convDict objectForKey:@"PlaceId"] integerValue]];
            
            hasNew = hasNew + isNewConv;
            i++;
        }
        if(i == 0)
        {
            for(RCConversation *conv in [RCConversation getAllRecords])
            {
                [RCConversation deleteInContext:conv];
            }
            
            [RCConversation saveDefaultContext];
        }
        
        if(completionBlock)
        {
            completionBlock(hasNew, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error with getConversationsFormServer : %@", error.description);
        if(completionBlock)
        {
            completionBlock(0, error);
        }
    }];
    
    [operation start];
}


-(NSMutableArray *)getBubblesFromConversation:(RCConversation *)conversation  myUserId:(NSString *)myUserId
{
    NSMutableArray *temp = [NSMutableArray new];
    for(RCMessage *message in conversation.messages)
    {
        //NSLog(@"%i   %i    %@", [message.user.userId integerValue], myUserId,  message.messageDate );
        if(![message.user.userId isEqual:myUserId])
        {
            NSBubbleData *someoneBubble = [NSBubbleData dataWithText:message.messageText date:message.messageDate == nil ? [NSDate date] : message.messageDate  type:BubbleTypeSomeoneElse];
            someoneBubble.message = message;
            someoneBubble.avatarUrl = message.user.avatarUrl;
            [temp addObject:someoneBubble];
        }
        else
        {
            NSBubbleData *sayBubble = [NSBubbleData dataWithText:message.messageText date:message.messageDate == nil ? [NSDate date] : message.messageDate  type:BubbleTypeMine];
            sayBubble.message = message;

            sayBubble.avatarUrl = message.user.avatarUrl;
            [temp addObject:sayBubble];
        }

    }
    
    return temp;
}

-(void)sendMessageFromUserId:(NSString *)userId messageText:(NSString *)messageText placeId:(NSInteger)placeId subj:(NSString *)subj completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@Message/Send", VibePath];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get sendMessageFromUserId url : %@, placeId: %i", urlString, placeId);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *arr = @{@"UserId":userId,@"PlaceId":[NSNumber numberWithInt:placeId],@"Text":messageText == nil ? @"" : messageText,@"Subject":@""};
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

-(void)addUserToPlaceTalk:(NSString *)userId placeId:(NSInteger)placeId completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@Participate/Add", VibePath];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get addUserToPlaceTalk url : %@, placeid %i", urlString, placeId);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *arr = @{@"UserId":userId,@"PlaceId":[NSNumber numberWithInt:placeId]};
    [client setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [client postPath:@"" parameters:arr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"addUserToPlaceTalk %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        completionBlock(YES, nil);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error addUserToPlaceTalk %@", [error description]);
        
        completionBlock(NO, error);
    }];
    
}


-(void)removeUserFromPlaceTalk:(NSString *)userId placeId:(NSInteger)placeId completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@Participate/Add", VibePath];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get removeUserFromPlaceTalk url : %@, placeid %i   user %@", urlString, placeId, userId);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *arr = @{@"UserId":userId,@"PlaceId":[NSNumber numberWithInt:placeId], @"Exclude":@"true"};
    [client setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [client postPath:@"" parameters:arr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"removeUserFromPlaceTalk %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        completionBlock(YES, nil);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error removeUserFromPlaceTalk %@", [error description]);
        
        completionBlock(NO, error);
    }];
    
}


-(void)registerUser:(NSString *)userId deviceToken:(NSString *)deviceToken completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@User/RegisterDevice", VibePath];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get registerUser url : %@", urlString);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *arr = @{@"UserId":userId,@"NotificationId":deviceToken};
    [client setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];
    [client postPath:@"" parameters:arr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"registerUser %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        completionBlock(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error registerUser %@", [error description]);
        
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
