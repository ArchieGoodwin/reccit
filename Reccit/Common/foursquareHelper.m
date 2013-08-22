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
        NSLog(@"%@", checkin);
        placeName = [placeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        placeName = [placeName stringByReplacingOccurrencesOfString:@"'" withString:@""];
        placeName = [placeName stringByReplacingOccurrencesOfString:@"&" withString:@""];

        placeName = [self stringWithPercentEscape:placeName];


        
        
        NSDictionary *loc = [[checkin objectForKey:@"venue"] objectForKey:@"location"];
        
        NSDictionary *locArray = @{@"latitude":[loc objectForKey:@"lat"],
                                   @"longitude":[loc objectForKey:@"lng"]
                                   };

    
        
        
        
        NSMutableArray *foodStyles = [NSMutableArray new];
        for(NSDictionary *style in [[checkin objectForKey:@"venue"] objectForKey:@"categories"])
        {
            NSString *s = [[style objectForKey:@"shortName"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@"&" withString:@""];
            s = [s stringByReplacingOccurrencesOfString:@"/" withString:@""];
            
            
            
            [foodStyles addObject:s];
        }
        NSString *foodStylesStr = [foodStyles componentsJoinedByString:@","];
        
        
        
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
        

        
        NSString *phone = @"";
        if([[[checkin objectForKey:@"venue"] objectForKey:@"contact"] objectForKey:@"phone"] != nil)
        {
            phone = [[[checkin objectForKey:@"venue"] objectForKey:@"contact"] objectForKey:@"phone"];
        }
        
       
        NSDictionary *placeArray = @{@"id":[[checkin objectForKey:@"venue"] objectForKey:@"id"],
                                     @"location":locArray,
                                     @"name":placeName,
                                     @"city":[loc objectForKey:@"city"] == nil ? @"" : [loc objectForKey:@"city"],
                                     @"country":[loc objectForKey:@"country"] == nil ? @"" : [loc objectForKey:@"country"],
                                     @"state":[loc objectForKey:@"state"] == nil ? @"" : [loc objectForKey:@"state"],
                                     @"street":[loc objectForKey:@"address"] == nil ? @"" : [[self stringWithPercentEscape:[loc objectForKey:@"address"]] stringByReplacingOccurrencesOfString:@"\"" withString:@""],
                                     
                                     @"zip":[loc objectForKey:@"postalCode"] == nil ? @"" : [loc objectForKey:@"postalCode"],
                                     @"phone":phone,
                                     @"type":categoriesString,
                                     @"pic":[self stringWithPercentEscape:[[checkin objectForKey:@"venue"] objectForKey:@"canonicalUrl"]],
                                     @"price_range":@"",
                                     
                                    @"food_styles":foodStylesStr
                                     
                                     };
        
        NSDictionary *item = @{@"author_uid":[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId],
                               @"checkin_id":[checkin objectForKey:@"id"],
                               
                               @"coords":locArray,
                               @"name":placeName,
                               @"page_id":[[checkin objectForKey:@"venue"] objectForKey:@"id"],
                               
                               @"place":placeArray};
        
        [temp addObject:item];
        
    }

    _checkinsArray = temp;
    NSLog(@"result for friends 4s send count %i:", temp.count);

    
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
