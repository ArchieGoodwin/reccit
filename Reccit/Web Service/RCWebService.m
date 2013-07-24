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
#import "AFNetworking.h"
#import "RCCommonUtils.h"
#import "MBProgressHUD.h"
#define kUserUrl @"http://bizannouncements.com/Vega/services/app/getUser.php?auth=fbook&token=%@"
#define kUserUrlTwitter @"http://bizannouncements.com/Vega/services/app/getUser.php?auth=twitter&token=%@"

#define kTwitterFriendsUrl @"http://bizannouncements.com/Vega/services/app/twitter.php"


@implementation RCWebService

+ (void)authenticateFacebookWithToken:(NSString *)token userId:(NSString *)userId
{
    
    NSString *urlString = [NSString stringWithFormat:kRCAPIFacebookAuthenticateDOTNET, token, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId]];
    /*if (userId != nil)
    {
        urlString = [NSString stringWithFormat:@"%@&userid=%@", [NSString stringWithFormat:kRCAPIFacebookAuthenticate, token, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId]], userId];
    }*/
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"get user first url : %@", urlString);

    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rO = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSLog(@"register user %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"register user %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]]];
        NSString *userFromServer = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if(!userId)
        {
            
            [[NSUserDefaults standardUserDefaults] setObject:userFromServer forKey:kRCUserId];
            //[[NSUserDefaults standardUserDefaults] setObject:@"535" forKey:kRCUserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];
        
            
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fLogin" object:self userInfo:nil];

        }
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"fcheckin"] == nil)
        {
            Sequencer *sequencer = [[Sequencer alloc] init];
            __block int iterations = 1;
            int period = 15768000;
            NSLog(@"start query %@", [NSDate date]);
            
            [sequencer enqueueStep:^(id result, SequencerCompletion completion) {
                [[facebookHelper sharedInstance] getFacebookUserCheckins:^(BOOL result, NSError *error) {
                    if([[facebookHelper sharedInstance] userCheckinsArray])
                    {
                        NSURL *userCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendUserChekinsDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]];
                        NSLog(@"get userCheckinRequest: %@", [NSString stringWithFormat:kSendUserChekinsDOTNET, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]);
                        
                        
                        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:userCheckinUrl];
                        [client setParameterEncoding:AFJSONParameterEncoding];
                        
                        //[client setDefaultHeader:@"Accept" value:@"application/json"];

                        //[client setDefaultHeader:@"X-Requested-With" value:@"XMLHttpRequest"];

                        //[client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringUserCheckins].length]];
                        [client postPath:@"" parameters:@{@"data":[[facebookHelper sharedInstance] userCheckinsArray]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"[userCheckinRequest responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                            //NSLog(@"userCheckinRequest:  %@",responseObjectUser);
                            
                            [[NSUserDefaults standardUserDefaults] setObject:@"fcheckin" forKey:@"fcheckin"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [TestFlight passCheckpoint:[NSString stringWithFormat:@"userCheckinRequest  %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                            completion([NSNumber numberWithBool:YES]);
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"error userCheckinRequest %@", [error description]);
                            [TestFlight passCheckpoint:[NSString stringWithFormat:@"error userCheckinRequest %@  %@", [NSDate date], [error description]]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"fLoginError" object:error userInfo:nil];
                            
                            completion([NSNumber numberWithBool:YES]);
                        }];
                        
                       
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
                     if([[facebookHelper sharedInstance] friendsCheckinsArray])
                     {
                         
                         NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                                     [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]];
                         NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                             [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]);
                         
                         AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:frCheckinUrl];
                         [client setParameterEncoding:AFJSONParameterEncoding];
                         //[client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                         [client postPath:@"" parameters:@{@"data":[[facebookHelper sharedInstance] friendsCheckinsArray]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                             //NSLog(@"userCheckinRequest:  %@",responseObjectUser);
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest  %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                             iterations++;
                             completion([NSNumber numberWithBool:YES]);
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"error frCheckinRequest %@", [error description]);
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest %@  %@", [NSDate date], [error description]]];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"fLoginError" object:error userInfo:nil];
                             iterations++;
                             completion([NSNumber numberWithBool:YES]);
                         }];
                         
                
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
                     if([[facebookHelper sharedInstance] friendsCheckinsArray])
                     {
                         
                         NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                                     [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]];
                         NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                             [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]);
                         
                         AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:frCheckinUrl];
                         [client setParameterEncoding:AFJSONParameterEncoding];
                         //[client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                         [client postPath:@"" parameters:@{@"data":[[facebookHelper sharedInstance] friendsCheckinsArray]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                             //NSLog(@"userCheckinRequest:  %@",responseObjectUser);
                             
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest  %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                             iterations++;
                             completion([NSNumber numberWithBool:YES]);
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"error frCheckinRequest %@", [error description]);
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest %@  %@", [NSDate date], [error description]]];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"fLoginError" object:error userInfo:nil];
                             iterations++;
                             completion([NSNumber numberWithBool:YES]);
                         }];
                         
                       
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
                     if([[facebookHelper sharedInstance] friendsCheckinsArray])
                     {
                         
                         NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                                     [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]];
                         NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                             [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]);
                         AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:frCheckinUrl];
                         [client setParameterEncoding:AFJSONParameterEncoding];
                         //[client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                         [client postPath:@"" parameters:@{@"data":[[facebookHelper sharedInstance] friendsCheckinsArray]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                             //NSLog(@"userCheckinRequest:  %@",responseObjectUser);
                             iterations++;
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest  %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                             completion([NSNumber numberWithBool:YES]);
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"error frCheckinRequest %@", [error description]);
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest %@  %@", [NSDate date], [error description]]];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"fLoginError" object:error userInfo:nil];
                             iterations++;
                             completion([NSNumber numberWithBool:YES]);
                         }];
                         
                  
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
                     if([[facebookHelper sharedInstance] friendsCheckinsArray])
                     {
                         
                         NSURL *frCheckinUrl = [NSURL URLWithString:[NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                                     [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]];
                         NSLog(@"get frCheckinRequest: %@", [NSString stringWithFormat:kSendFriendsChekinsDOTNET,
                                                             [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId], token]);
                         AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:frCheckinUrl];
                         [client setParameterEncoding:AFJSONParameterEncoding];
                         [client setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [[facebookHelper sharedInstance] stringFriendsCheckins].length]];
                         [client postPath:@"" parameters:@{@"data":[[facebookHelper sharedInstance] friendsCheckinsArray]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             NSLog(@"[frCheckinRequest responseData]: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                             //NSLog(@"userCheckinRequest:  %@",responseObjectUser);
                             iterations++;
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"frCheckinRequest  %@ %@", [NSDate date], [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
                             completion([NSNumber numberWithBool:YES]);
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"error frCheckinRequest %@", [error description]);
                             [TestFlight passCheckpoint:[NSString stringWithFormat:@"error frCheckinRequest %@  %@", [NSDate date], [error description]]];
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"fLoginError" object:error userInfo:nil];
                             iterations++;
                             completion([NSNumber numberWithBool:YES]);
                         }];
                         
                  
                     }
                 }];
                 
             }];
            
            [sequencer run];
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error register user %@", [error description]);
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"error register user %@  %@", [NSDate date], [error description]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fRegisterError" object:error userInfo:nil];

        
    }];
    
    [operation start];
    
    
    
  
}




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
    __strong ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
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
                    __strong ASIHTTPRequest *userCheckinRequest = [ASIHTTPRequest requestWithURL:userCheckinUrl];
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
    __strong ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
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
                    __strong ASIHTTPRequest *userCheckinRequest = [ASIHTTPRequest requestWithURL:userCheckinUrl];
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
