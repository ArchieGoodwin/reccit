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

-(void)getCheckins:(NSString *)token completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    
    iterations = 0;
    maxIterations = 1;
    NSLog(@"start query 4s %@", [NSDate date]);
    
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
        //NSLog(@"%@", placeName);
        placeName = [placeName stringByReplacingOccurrencesOfString:@"(" withString:@" "];
        placeName = [placeName stringByReplacingOccurrencesOfString:@")" withString:@" "];
        placeName = [placeName stringByReplacingOccurrencesOfString:@"&" withString:@" "];
        placeName = [placeName stringByReplacingOccurrencesOfString:@"'" withString:@""];

     
        NSDictionary *loc = [[checkin objectForKey:@"venue"] objectForKey:@"location"];
        NSArray *locArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue:@"latitude" value:[loc objectForKey:@"lat"]],
                             [self makeStringWithKeyAndValue:@"longitude" value:[loc objectForKey:@"lng"]],
                             nil];
        
        NSArray *friendCheckinArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"author_uid" value:@"2"],//[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]],
                                       [self makeStringWithKeyAndValue:@"checkin_id" value:[checkin objectForKey:@"id"]],
                                       [self makeStringWithKeyAndValue:@"name" value:[placeName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                                       [self makeStringWithKeyAndValue:@"page_id" value:[[checkin objectForKey:@"venue"] objectForKey:@"id"]],
                                       [self makeStringWithKeyAndValue2:@"coords" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                       nil];
        
        //place dictionary building
        NSMutableArray *foodStyles = [NSMutableArray new];
        for(NSDictionary *style in [[checkin objectForKey:@"venue"] objectForKey:@"categories"])
        {
            [foodStyles addObject:[style objectForKey:@"shortName"]];
        }
        NSString *foodStyleString = [NSString stringWithFormat:@"\"food_styles\":\"%@\"", [foodStyles componentsJoinedByString:@","]];
        
        
        NSMutableArray *categories = [NSMutableArray new];
        for(NSDictionary *style in [[checkin objectForKey:@"venue"] objectForKey:@"categories"])
        {
            [categories addObject:[style objectForKey:@"shortName"]];
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
                               [self makeStringWithKeyAndValue:@"name" value:[placeName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                               [self makeStringWithKeyAndValue:@"city" value:[loc objectForKey:@"city"]],
                               [self makeStringWithKeyAndValue:@"country" value:[loc objectForKey:@"country"]],
                               [self makeStringWithKeyAndValue:@"state" value:[loc objectForKey:@"state"]],
                               [self makeStringWithKeyAndValue:@"street" value:[[[loc objectForKey:@"address"]
                                                                                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@" "]],
                               [self makeStringWithKeyAndValue:@"zip" value:[loc objectForKey:@"postalCode"]],
                               [self makeStringWithKeyAndValue:@"phone" value:phone],
                               [self makeStringWithKeyAndValue:@"type" value:categoriesString],
                               [self makeStringWithKeyAndValue:@"pic" value:[[[checkin objectForKey:@"venue"] objectForKey:@"canonicalUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                               [self makeStringWithKeyAndValue:@"price_range" value:@""],
                               [self makeStringWithKeyAndValue:@"website" value:[[[[checkin objectForKey:@"venue"] objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@""]],
                               hoursString,
                               foodStyleString,
                               
                               nil];
        NSString *place = [NSString stringWithFormat:@"\"place\":{%@}", [placeArray componentsJoinedByString:@","]];
        
        NSString *item = [NSString stringWithFormat:@"{%@,%@}", [friendCheckinArray componentsJoinedByString:@","], place];
        [temp addObject:item];

        
    }
    
    
    NSString *data = [NSString stringWithFormat:@"fb_usercheckin={\"data\":[%@]}",[temp componentsJoinedByString:@","]];
    
    NSLog(@"result for friends 4s send count %i: %@", temp.count, data);
    _stringUserCheckins = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
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
