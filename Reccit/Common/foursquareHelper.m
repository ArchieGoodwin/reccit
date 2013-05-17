//
//  foursquareHelper.m
//  Reccit
//
//  Created by Nero Wolfe on 5/3/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "foursquareHelper.h"
#import "AFNetworking.h"
#import "RCDefine.h"

@implementation foursquareHelper
{
    int iterations;
    int maxIterations;
    NSDictionary *mySelf;
    NSString *userid;
    NSString *userName;
}
-(void)getCheckinsRecursive:(NSString *)token offset:(int)offset completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    NSString *connectionString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/users/self/checkins?oauth_token=%@&limit=250&offset=%i", token, offset];
    NSLog(@"%@", connectionString);
    NSURL *url = [NSURL URLWithString:connectionString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"step %i : ", iterations);
        [self buildArrays:[[[JSON objectForKey:@"response"] objectForKey:@"checkins"] objectForKey:@"items"]];
        NSLog(@"step recursiveQuery %i", iterations);
        iterations++;
        if(iterations <= maxIterations)
        {
            [self getCheckinsRecursive:token offset:iterations * 250 completionBlock:completionBlock];
            
        }
        else
        {
            [self buildResult];
            NSLog(@"end query 4s %@", [NSDate date]);
            
            if(completionBlock)
            {
                completionBlock(YES, nil);
            }
        }
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        completionBlock(nil, error);
    }];
    
    [operation start];
}


-(void)getSelf:(NSString *)token completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;
    
    
    
    
    NSString *connectionString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/users/self?oauth_token=%@", token];
    NSLog(@"%@", connectionString);
    NSURL *url = [NSURL URLWithString:connectionString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"%@", JSON);
        mySelf = JSON;
        userid = [[[mySelf objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        userName = [NSString stringWithFormat:@"%@ %@", [[[mySelf objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"firstName"], [[[mySelf objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"lastName"]];

        completeBlockWithResult(YES, nil);
   
        
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        completeBlockWithResult(nil, error);
    }];
    
    [operation start];
}

-(void)getCheckins:(NSString *)token completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    
    iterations = 0;
    maxIterations = 1;
    NSLog(@"start query 4s %@", [NSDate date]);
    
    [self getSelf:token completionBlock:^(BOOL result, NSError *error) {
        if(result)
        {
            NSString *connectionString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/users/self/checkins?oauth_token=%@&limit=250&offset=0", token];
            NSLog(@"%@", connectionString);
            NSURL *url = [NSURL URLWithString:connectionString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            AFJSONRequestOperation *operation;
            operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                //NSLog(@"%@", [[JSON objectForKey:@"response"] objectForKey:@"checkins"]);
                int count = [[[[JSON objectForKey:@"response"] objectForKey:@"checkins"] objectForKey:@"count"] integerValue];
                NSLog(@"Checkins count %i", count);
                maxIterations = count / 250;
                
                [self buildArrays:[[[JSON objectForKey:@"response"] objectForKey:@"checkins"] objectForKey:@"items"]];
                
                if(count > 250)
                {
                    iterations++;
                    [self getCheckinsRecursive:token offset:iterations * 250 completionBlock:completeBlockWithResult];
                }
                else
                {
                    [self buildResult];
                    completeBlockWithResult(YES, nil);
                    
                }
                
                
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                
                completeBlockWithResult(nil, error);
            }];
            
            [operation start];
        }
    }];
    
    
    
    
   
}

-(NSString*)stringWithPercentEscape:(NSString *)str {
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[str mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8));
}


-(void)buildArrays:(NSMutableArray *)array
{

    [_checkins addObjectsFromArray:array];

    
    NSLog(@"result arrays 4s :%i ", _checkins.count);
}

-(void)buildResult
{
    NSMutableArray *temp = [NSMutableArray new];
    if(_checkins.count == 0)
    {
        _stringUserCheckins = nil;
        return;
    }
    
    for(NSDictionary *checkin in _checkins)
    {
        
        NSString *placeName = [[checkin objectForKey:@"venue"] objectForKey:@"name"];
        //NSLog(@"%@", checkin);
        placeName = [placeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        placeName = [placeName stringByReplacingOccurrencesOfString:@"'" withString:@""];
        placeName = [placeName stringByReplacingOccurrencesOfString:@"&" withString:@""];

        placeName = [self stringWithPercentEscape:placeName];


        
        
        NSDictionary *loc = [[checkin objectForKey:@"venue"] objectForKey:@"location"];
        NSArray *locArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue:@"latitude" value:[loc objectForKey:@"lat"]],
                             [self makeStringWithKeyAndValue:@"longitude" value:[loc objectForKey:@"lng"]],
                             nil];
        
        
        NSArray *fromArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue:@"id" value:userid],
                              [self makeStringWithKeyAndValue:@"name" value:userName],
                              nil];
        NSString *from = [NSString stringWithFormat:@"\"from\":{%@}", [fromArray componentsJoinedByString:@","]];
        

        
        
        
        /*NSArray *friendCheckinArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"author_uid" value:@"2"],//[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]],
                                       [self makeStringWithKeyAndValue:@"checkin_id" value:[checkin objectForKey:@"id"]],
                                       [self makeStringWithKeyAndValue:@"name" value:[placeName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                                       [self makeStringWithKeyAndValue:@"page_id" value:[[checkin objectForKey:@"venue"] objectForKey:@"id"]],
                                       [self makeStringWithKeyAndValue2:@"coords" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                       nil];
        */
        //place dictionary building
        NSMutableArray *foodStyles = [NSMutableArray new];
        for(NSDictionary *style in [[checkin objectForKey:@"venue"] objectForKey:@"categories"])
        {
            
            NSString *s = [[style objectForKey:@"shortName"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@"&" withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@"/" withString:@""];
            
            
            
            [foodStyles addObject:s];
        }
        NSString *foodStyleString = [NSString stringWithFormat:@"\"food_styles\":\"%@\"", [foodStyles componentsJoinedByString:@","]];
        
        
        NSMutableArray *categories = [NSMutableArray new];

        for(NSDictionary *style in [[checkin objectForKey:@"venue"] objectForKey:@"categories"])
        {
            for(NSString *str in  [style objectForKey:@"parents"])
            {
                NSString *s = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                s = [s stringByReplacingOccurrencesOfString:@"&" withString:@""];
                s = [s stringByReplacingOccurrencesOfString:@"/" withString:@""];
                
                [categories addObject:s];

            }
        }
        NSString *categoriesString = [NSString stringWithFormat:@"%@", [categories componentsJoinedByString:@","]];
        
        

        
        NSString *hoursString = [NSString stringWithFormat:@"\"hours\":{%@}", @""];

        NSString *phone = @"";
        if([[[checkin objectForKey:@"venue"] objectForKey:@"contact"] respondsToSelector:@selector(objectForKey:)])
        {
            phone = [[[checkin objectForKey:@"venue"] objectForKey:@"contact"] objectForKey:@"phone"];
        }
        
        NSArray *placeArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue:@"id" value:[[checkin objectForKey:@"venue"] objectForKey:@"id"]],
                               [self makeStringWithKeyAndValue2:@"location" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                               [self makeStringWithKeyAndValue:@"name" value:placeName],
                               [self makeStringWithKeyAndValue:@"city" value:[loc objectForKey:@"city"]],
                               [self makeStringWithKeyAndValue:@"country" value:[loc objectForKey:@"country"]],
                               [self makeStringWithKeyAndValue:@"state" value:[loc objectForKey:@"state"]],
                               [self makeStringWithKeyAndValue:@"street" value:[[self stringWithPercentEscape:[loc objectForKey:@"address"]] stringByReplacingOccurrencesOfString:@"\"" withString:@""]],
                               [self makeStringWithKeyAndValue:@"zip" value:[loc objectForKey:@"postalCode"]],
                               [self makeStringWithKeyAndValue:@"phone" value:phone],
                               [self makeStringWithKeyAndValue:@"type" value:categoriesString],
                               [self makeStringWithKeyAndValue:@"pic" value:[self stringWithPercentEscape:[[checkin objectForKey:@"venue"] objectForKey:@"canonicalUrl"]]],
                               [self makeStringWithKeyAndValue:@"price_range" value:@""],
                               [self makeStringWithKeyAndValue:@"website" value:[self stringWithPercentEscape:[[checkin objectForKey:@"venue"] objectForKey:@"url"]]],
                               hoursString,
                               foodStyleString,
                               
                               nil];
        NSString *place = [NSString stringWithFormat:@"\"place\":{%@}", [placeArray componentsJoinedByString:@","]];
        
        NSString *item = [NSString stringWithFormat:@"{%@,%@,%@}", from, [self makeStringWithKeyAndValue:@"id" value:[checkin objectForKey:@"id"]], place];
        [temp addObject:item];

        
    }
    
    
    NSString *data = [NSString stringWithFormat:@"fb_usercheckin={\"data\":[%@]}",[temp componentsJoinedByString:@","]];
    
    NSLog(@"result for friends 4s send count %i: %@", temp.count, data);
    _stringUserCheckins = data;
    
}



-(NSString *)makeStringWithKeyAndValue:(NSString *)key value:(NSString *)value
{
    
    return [NSString stringWithFormat:@"\"%@\":\"%@\"", key, value];
    
    
    
}

-(NSString *)makeStringWithKeyAndValue2:(NSString *)key value:(NSString *)value
{
    
    return [NSString stringWithFormat:@"\"%@\":%@", key, value];
    
    
    
}

- (id)init {
    self = [super init];
    
    _checkins = [NSMutableArray new];
    _places = [NSMutableArray new];
    
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    
#else
    
    
#endif
    
    return self;
    
}



+(id)sharedInstance
{
    static dispatch_once_t pred;
    static foursquareHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[foursquareHelper alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{
    
    abort();
}


@end
