//
//  foursquareHelper.m
//  Reccit
//
//  Created by Nero Wolfe on 5/3/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "foursquareHelper.h"
#import "AFNetworking.h"
@implementation foursquareHelper





-(void)getCheckins
{
    NSString *connectionString = [NSString stringWithFormat:@"http://free.worldweatheronline.com/feed/weather.ashx?q=%f,%f&format=json&num_of_days=2&key=b603d14d52054854131903", lat, lng];
    NSLog(@"%@", connectionString);
    NSURL *url = [NSURL URLWithString:connectionString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"%@", JSON);
        
        
        //if([[json objectForKey:@"numResults"] integerValue] > 0)
        //{
        NWWeather *item = [[NWWeather alloc] initWithDictionary:[JSON objectForKey:@"data"]];;
        
        
        
        completeBlock(item, nil);
        
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        completeBlock(nil, error);
    }];
    
    [operation start];
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
