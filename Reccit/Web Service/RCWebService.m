//
//  RCWebService.m
//  Reccit
//
//  Created by Lee Way on 1/28/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCWebService.h"
#import "ASIHTTPRequest.h"
#import "RCDefine.h"
#import "facebookHelper.h"
#import "foursquareHelper.h"
#import "twitterHelper.h"
#import "TestFlight.h"
#import "Sequencer.h"
#define kUserUrl @"http://bizannouncements.com/Vega/services/app/getUser.php?auth=fbook&token=%@"
#define kUserUrlTwitter @"http://bizannouncements.com/Vega/services/app/getUser.php?auth=twitter&token=%@"

#define kTwitterFriendsUrl @"http://bizannouncements.com/Vega/services/app/twitter.php"


@implementation RCWebService

+ (void)authenticateFacebookWithToken:(NSString *)token userId:(NSString *)userId
{
    NSString *urlString = [NSString stringWithFormat:kRCAPIFacebookAuthenticate, token];
    if (userId != nil)
    {
        urlString = [NSString stringWithFormat:@"%@&userid=%@", [NSString stringWithFormat:kRCAPIFacebookAuthenticate, token], userId];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get user first url : %@", urlString);

    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    //[request setRequestMethod:@"POST"];
    [request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:nil];
        NSLog(@"register user %@", [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding]);
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"register user %@", [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding]]];

        if(!userId)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"userId"] forKey:kRCUserId];
            //[[NSUserDefaults standardUserDefaults] setObject:@"535" forKey:kRCUserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];

        }

        
        Sequencer *sequencer = [[Sequencer alloc] init];
        __block int iterations = 1;
        int period = 15768000;
        NSLog(@"start query %@", [NSDate date]);
        
        [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
            [[facebookHelper sharedInstance] getFacebookUserCheckins:^(BOOL result, NSError *error) {
                if([[facebookHelper sharedInstance] stringUserCheckins])
                {
                    NSURL *userCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                    NSLog(@"get userCheckinRequest: %@", [NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                    __weak ASIHTTPRequest *userCheckinRequest = [ASIHTTPRequest requestWithURL:userCheckinUrl];
                    [userCheckinRequest setRequestMethod:@"POST"];
                    userCheckinRequest.timeOutSeconds = 120;
                    [userCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                    //NSString *str = [@"fb_usercheckin={\"data\":[{\"from\":{\"id\":715246241,\"name\":\"Sergey Dikarev\"},\"id\":10151385996696242,\"place\":{\"id\":276390062443754,\"location\":{\"latitude\":\"47.210743021951\",\"longitude\":\"38.932179656663\"},\"name\":\"qqqqq\"}}]}" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [userCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringUserCheckins].length]];
                    [userCheckinRequest setPostBody:[[[[facebookHelper sharedInstance] stringUserCheckins] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
                    
                    
                    [userCheckinRequest setFailedBlock:^{
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];
                        NSLog(@"error userCheckinRequest %@", [userCheckinRequest.error description]);
                        [TestFlight passCheckpoint:[NSString stringWithFormat:@"error userCheckinRequest %@  %@", [NSDate date], [userCheckinRequest.error description]]];
                        completion([NSNumber numberWithBool:YES]);
                    }];
                    [userCheckinRequest setCompletionBlock:^{
                        
                        NSLog(@"[userCheckinRequest responseData]: %@", [[NSString alloc] initWithData:[userCheckinRequest responseData] encoding:NSUTF8StringEncoding]);
                        //NSLog(@"userCheckinRequest:  %@",responseObjectUser);
                        [TestFlight passCheckpoint:[NSString stringWithFormat:@"userCheckinRequest  %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                        completion([NSNumber numberWithBool:YES]);
                        
                    }];
                    
                    
                    [userCheckinRequest startAsynchronous];
                }
                else
                {
                    completion([NSNumber numberWithBool:YES]);

                }

            }];
        }];

        [sequencer enqueueStep:^(id result, SequencerCompletion completion)
         {
             
             
             [[facebookHelper sharedInstance] facebookQueryWithTimePaging:iterations *period completionBlock:^(BOOL result, NSError *error) {
                 if([[facebookHelper sharedInstance] stringFriendsCheckins])
                 {
                     
                     NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekins,
                                                                 [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                     NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                     __weak ASIHTTPRequest *frCheckinRequest = [ASIHTTPRequest requestWithURL:frCheckinUrl];
                     frCheckinRequest.requestMethod = @"POST";
                     frCheckinRequest.timeOutSeconds = 240;
                     
                     [frCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                     [frCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                     [frCheckinRequest setPostBody:[[[[facebookHelper sharedInstance] stringFriendsCheckins] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
                     [frCheckinRequest setFailedBlock:^{
                         NSLog(@"error frCheckinRequest %@", [frCheckinRequest.error description]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest step %i %@  %@", iterations, [NSDate date], [frCheckinRequest.error description]]];
                         iterations++;
                         
                         completion([NSNumber numberWithBool:YES]);
                     }];
                     [frCheckinRequest setCompletionBlock:^{
                         NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:[frCheckinRequest responseData] encoding:NSUTF8StringEncoding]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest step %i %@ %@", iterations, [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                         iterations++;
                         
                         completion([NSNumber numberWithBool:YES]);
                     }];
                     
                     [frCheckinRequest startAsynchronous];
                 }
                 else
                 {
                     completion([NSNumber numberWithBool:YES]);

                 }
             }];
             
         }];
        [sequencer enqueueStep:^(NSNumber *success, SequencerCompletion completion)
         {
             [[facebookHelper sharedInstance] facebookQueryWithTimePaging:iterations *period completionBlock:^(BOOL result, NSError *error) {
                 if([[facebookHelper sharedInstance] stringFriendsCheckins])
                 {
                     
                     NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekins,
                                                                 [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                     NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                     __weak ASIHTTPRequest *frCheckinRequest = [ASIHTTPRequest requestWithURL:frCheckinUrl];
                     frCheckinRequest.requestMethod = @"POST";
                     frCheckinRequest.timeOutSeconds = 240;
                     
                     [frCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                     [frCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                     [frCheckinRequest setPostBody:[[[[facebookHelper sharedInstance] stringFriendsCheckins] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
                     [frCheckinRequest setFailedBlock:^{
                         NSLog(@"error frCheckinRequest %@", [frCheckinRequest.error description]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest step %i %@  %@", iterations, [NSDate date], [frCheckinRequest.error description]]];
                         iterations++;
                         
                         completion([NSNumber numberWithBool:YES]);
                     }];
                     [frCheckinRequest setCompletionBlock:^{
                         NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:[frCheckinRequest responseData] encoding:NSUTF8StringEncoding]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest step %i %@ %@", iterations, [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                         iterations++;
                         
                         completion([NSNumber numberWithBool:YES]);
                     }];
                     
                     [frCheckinRequest startAsynchronous];
                 }
                 else
                 {
                     completion([NSNumber numberWithBool:YES]);

                     
                 }
             }];
             
         }];
        [sequencer enqueueStep:^(NSNumber *success, SequencerCompletion completion)
         {
             [[facebookHelper sharedInstance] facebookQueryWithTimePaging:iterations *period completionBlock:^(BOOL result, NSError *error) {
                 if([[facebookHelper sharedInstance] stringFriendsCheckins])
                 {
                     
                     NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekins,
                                                                 [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                     NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                     __weak ASIHTTPRequest *frCheckinRequest = [ASIHTTPRequest requestWithURL:frCheckinUrl];
                     frCheckinRequest.requestMethod = @"POST";
                     frCheckinRequest.timeOutSeconds = 240;
                     
                     [frCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                     [frCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                     [frCheckinRequest setPostBody:[[[[facebookHelper sharedInstance] stringFriendsCheckins] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
                     [frCheckinRequest setFailedBlock:^{
                         NSLog(@"error frCheckinRequest %@", [frCheckinRequest.error description]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest step %i %@  %@", iterations, [NSDate date], [frCheckinRequest.error description]]];
                         iterations++;
                         
                         completion([NSNumber numberWithBool:YES]);
                     }];
                     [frCheckinRequest setCompletionBlock:^{
                         NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:[frCheckinRequest responseData] encoding:NSUTF8StringEncoding]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest step %i %@ %@", iterations, [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                         iterations++;
                         
                         completion([NSNumber numberWithBool:YES]);
                     }];
                     
                     [frCheckinRequest startAsynchronous];
                 }
                 else
                 {
                     completion([NSNumber numberWithBool:YES]);

                 }
             }];
             
         }];
        [sequencer enqueueStep:^(NSNumber *success, SequencerCompletion completion)
         {
             [[facebookHelper sharedInstance] facebookQueryWithTimePaging:iterations *period completionBlock:^(BOOL result, NSError *error) {
                 if([[facebookHelper sharedInstance] stringFriendsCheckins])
                 {
                     
                     NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekins,
                                                                 [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                     NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
                     __weak ASIHTTPRequest *frCheckinRequest = [ASIHTTPRequest requestWithURL:frCheckinUrl];
                     frCheckinRequest.requestMethod = @"POST";
                     frCheckinRequest.timeOutSeconds = 240;
                     
                     [frCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                     [frCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                     [frCheckinRequest setPostBody:[[[[facebookHelper sharedInstance] stringFriendsCheckins] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
                     [frCheckinRequest setFailedBlock:^{
                         NSLog(@"error frCheckinRequest %@", [frCheckinRequest.error description]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest step %i %@  %@", iterations, [NSDate date], [frCheckinRequest.error description]]];
                         iterations++;
                         
                         completion(nil);
                     }];
                     [frCheckinRequest setCompletionBlock:^{
                         NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:[frCheckinRequest responseData] encoding:NSUTF8StringEncoding]);
                         [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest step %i %@ %@", iterations, [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                         iterations++;
                         
                         completion(nil);
                     }];
                     
                     [frCheckinRequest startAsynchronous];
                 }
             }];
             
         }];
        
        [sequencer run];


    }];
    
    [request startAsynchronous];
}

/*[[facebookHelper sharedInstance] getFacebookQueryWithTimePaging:^(BOOL result, NSError *error) {
 if([[facebookHelper sharedInstance] stringFriendsCheckins])
 {
 
 NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekins,
 [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
 NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]);
 __weak ASIHTTPRequest *frCheckinRequest = [ASIHTTPRequest requestWithURL:frCheckinUrl];
 frCheckinRequest.requestMethod = @"POST";
 frCheckinRequest.timeOutSeconds = 240;
 
 [frCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
 [frCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
 [frCheckinRequest setPostBody:[[[facebookHelper sharedInstance] stringFriendsCheckins] dataUsingEncoding:NSUTF8StringEncoding]];
 [frCheckinRequest setFailedBlock:^{
 //[[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];
 NSLog(@"error frCheckinRequest %@", [frCheckinRequest.error description]);
 [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest %@  %@", [NSDate date], [frCheckinRequest.error description]]];
 
 }];
 [frCheckinRequest setCompletionBlock:^{
 NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:[frCheckinRequest responseData] encoding:NSUTF8StringEncoding]);
 [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest  %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
 
 }];
 
 [frCheckinRequest startAsynchronous];
 }
 }];*/


+ (void)authenticateTwitterWithToken:(NSString *)token userId:(NSString *)userId
{



    NSString *urlString = [NSString stringWithFormat:kRCAPITwitterAuthenticate, [[NSUserDefaults standardUserDefaults] objectForKey:@"tKey"], [[NSUserDefaults standardUserDefaults] objectForKey:@"tSecret"]];
    NSLog(@"twitter %@", urlString);
    if (userId != nil)
    {
        NSString *strTemp = [NSString stringWithFormat:kRCAPITwitterAuthenticate, [[NSUserDefaults standardUserDefaults] objectForKey:@"tKey"], [[NSUserDefaults standardUserDefaults] objectForKey:@"tSecret"]];
        
        urlString = [NSString stringWithFormat:@"%@&user=%@", strTemp, userId];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:nil];
        NSLog(@"authenticateTwitterWithToken %@", [responseObject objectForKey:@"User"]);
        if(!userId)
        {

                if(![[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId])
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"User"] forKey:kRCUserId];
                    //[[NSUserDefaults standardUserDefaults] setObject:@"535" forKey:kRCUserId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    

                    
                }
                //[[NSUserDefaults standardUserDefaults] setObject:@"434" forKey:kRCUserId];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tLogin" object:self userInfo:nil];

        }
        
        [[twitterHelper sharedInstance] storeAccountWithAccessToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"tKey"] secret:[[NSUserDefaults standardUserDefaults] objectForKey:@"tSecret"] completionBlock:^(BOOL result, NSError *error) {
            [[twitterHelper sharedInstance] getFollowers:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserName] completionBlock:^(BOOL result, NSError *error) {
                //here
                
                if([[twitterHelper sharedInstance] stringFriends])
                {
                    NSURL *userCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kTwitterFriendsUrl]];
                    __weak ASIHTTPRequest *userCheckinRequest = [ASIHTTPRequest requestWithURL:userCheckinUrl];
                    [userCheckinRequest setRequestMethod:@"POST"];
                    userCheckinRequest.timeOutSeconds = 720;

                    [userCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                    [userCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[twitterHelper sharedInstance] stringFriends].length]];
                    [userCheckinRequest setPostBody:[[[[twitterHelper sharedInstance] stringFriends] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
                    
                    [userCheckinRequest setFailedBlock:^{
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];
                        NSLog(@"[userCheckinRequest responseData] error: %@", [[NSString alloc] initWithData:[userCheckinRequest responseData] encoding:NSUTF8StringEncoding]);

                        
                    }];
                    [userCheckinRequest setCompletionBlock:^{
                        

                        NSLog(@"[userCheckinRequest responseData]: %@", [[NSString alloc] initWithData:[userCheckinRequest responseData] encoding:NSUTF8StringEncoding]);

                        
                    }];
                    
                    
                    [userCheckinRequest startAsynchronous];
                }
            }];
        }];
        
        

    }];
    
    [request startAsynchronous];
}

+ (void)authenticateFoursquareWithToken:(NSString *)token userId:(NSString *)userId
{
    NSString *urlString = [NSString stringWithFormat:kRCAPIFoursquareAuthenticate, token];
    if (userId != nil)
    {
        urlString = [NSString stringWithFormat:@"%@&user=%@", [NSString stringWithFormat:kRCAPIFoursquareAuthenticate, token], userId];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:nil];
        NSLog(@"%@", responseObject);
        
        [[foursquareHelper sharedInstance] getCheckins:token completionBlock:^(BOOL result, NSError *error) {
            //result
            
            if(result)
            {
                if([[foursquareHelper sharedInstance] stringUserCheckins])
                {
                    NSURL *userCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId], @"null"]];
                    NSLog(@"get userCheckinRequest 4s: %@", [NSString stringWithFormat:kSendUserChekins, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId],  @"null"]);
                    __weak ASIHTTPRequest *userCheckinRequest = [ASIHTTPRequest requestWithURL:userCheckinUrl];
                    [userCheckinRequest setRequestMethod:@"POST"];
                    userCheckinRequest.timeOutSeconds = 720;

                    [userCheckinRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
                    [userCheckinRequest addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[foursquareHelper sharedInstance] stringUserCheckins].length]];
                    [userCheckinRequest setPostBody:[[[[foursquareHelper sharedInstance] stringUserCheckins] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
                    
                    [userCheckinRequest setFailedBlock:^{
                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];
                        NSLog(@"[userCheckinRequest responseData]  4s error: %@", [[NSString alloc] initWithData:[userCheckinRequest responseData] encoding:NSUTF8StringEncoding]);

                    }];
                    [userCheckinRequest setCompletionBlock:^{
                        
                        
                        NSLog(@"[userCheckinRequest responseData]  4s: %@", [[NSString alloc] initWithData:[userCheckinRequest responseData] encoding:NSUTF8StringEncoding]);

                        
                    }];
                    
                    
                    [userCheckinRequest startAsynchronous];
                }
                else
                {
                    
                }
            }
            
            
        }];
        
        
    }];
    
    [request startAsynchronous];
}

@end
