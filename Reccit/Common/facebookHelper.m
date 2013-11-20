//
// Created by sdikarev on 4/11/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "facebookHelper.h"
#import "RCDefine.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TestFlight.h"
#import <FacebookSDK/FacebookSDK.h>
@implementation facebookHelper {
    int iterations;
    int maxIterations;
    int period;
}

-(void)recursiveQuery:(int)offset completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    NSString *query = [NSString stringWithFormat:
            @"{"
                    @"'query1':'SELECT uid2 FROM friend WHERE uid1 = me() LIMIT 300 OFFSET %i',"
                    @"'query2':'SELECT coords, author_uid, page_id, checkin_id FROM checkin WHERE author_uid IN (SELECT uid2 FROM #query1)',"
                    @"'query3':'select page_id, name, type, food_styles, hours, location, categories, "
                    "phone, pic, price_range, website "
                    "from page where type in (\"RESTAURANT/CAFE\", \"BAR\", \"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, name, "
                    "type FROM place WHERE page_id IN (SELECT page_id FROM #query2)) ',"
                    @"}", offset];


    //NSString *query = [NSString stringWithFormat:@"SELECT coords, author_uid, page_id FROM checkin WHERE author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) LIMIT 300 OFFSET %i", offset];

    // Set up the query parameter
    NSDictionary *queryParam =
            [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    // Make the API request that uses FQL

    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    postRequest.session = FBSession.activeSession;

    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {
            NSLog(@"step recursiveQuery %i", iterations);
            iterations++;
            //NSLog(@"getFacebookQuery > 300: %@", [result objectForKey:@"data"]);
            [self buildArrays:[result objectForKey:@"data"]];

            if(iterations <= maxIterations)
            {
                [self recursiveQuery:iterations * 300 completionBlock:completionBlock];

            }
            else
            {
                [self buildResult];
                NSLog(@"end query %@", [NSDate date]);
                //[TestFlight passCheckpoint:[NSString stringWithFormat:@"end facebook query %@", [NSDate date]]];

                if(completionBlock)
                {
                    completionBlock(YES, nil);
                }
            }
        }
        else
        {
            NSLog(@"error: %@", [error description]);
            if(completionBlock)
            {
                completionBlock(NO, error);
            }
        }
    }];
}

-(void)recursiveFacebookQueryWithTimePaging:(long)offset completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    NSLog(@"step recursiveQuery %i", iterations);

    long millis = [[NSDate date] timeIntervalSince1970];
    long down_t = millis - offset;
    long upper_t = down_t + period;
    NSLog(@"period: %li   %li   , current time %li", down_t, upper_t, millis);
    NSString *query = [NSString stringWithFormat:
                       @"{"
                       @"'query2':'SELECT coords, author_uid, page_id, checkin_id FROM checkin WHERE author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) AND timestamp > %li AND timestamp < %li',"
                       @"'query3':'select page_id, name, type, food_styles, hours, location, categories, "
                       "phone, pic, price_range, website "
                       "from page where type in (\"RESTAURANT/CAFE\", \"BAR\", \"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, name, "
                       "type FROM place WHERE page_id IN (SELECT page_id FROM #query2)) ',"
                       @"}", down_t, upper_t];
    
    

    // Set up the query parameter
    NSDictionary *queryParam =
    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    
    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    postRequest.session = FBSession.activeSession;
    
    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {
            iterations++;
            [self buildArrays:[result objectForKey:@"data"]];
            
            if(iterations <= maxIterations)
            {
                [self recursiveFacebookQueryWithTimePaging:iterations * period completionBlock:completionBlock];
                
            }
            else
            {
                [self buildResult];
                NSLog(@"end query %@", [NSDate date]);
                //[TestFlight passCheckpoint:[NSString stringWithFormat:@"end facebook query %@", [NSDate date]]];
                
                if(completionBlock)
                {
                    completionBlock(YES, nil);
                }
            }
        }
        else
        {
            NSLog(@"error: %@", [error description]);
            if(completionBlock)
            {
                completionBlock(NO, error);
            }
        }
    }];
}

-(void)facebookQueryWithTimePaging:(long)offset completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    NSLog(@"step recursiveQuery %i", iterations);
    
    [_checkins removeAllObjects];
    [_places removeAllObjects];
    _stringFriendsCheckins = @"";
    
    long millis = [[NSDate date] timeIntervalSince1970];
    long down_t = millis - offset;
    long upper_t = down_t + period;
    NSLog(@"period: %li   %li   , current time %li", down_t, upper_t, millis);
    NSString *query = [NSString stringWithFormat:
                       @"{"
                       @"'query2':'SELECT coords, author_uid, target_id, checkin_id FROM checkin WHERE author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) AND timestamp > %li AND timestamp < %li',"
                       @"'query3':'select page_id, name, type, food_styles, hours, location, categories, "
                       "phone, pic, price_range, website, pic_big "
                       "from page where type in (\"RESTAURANT/CAFE\", \"BAR\", \"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, name, "
                       "type FROM place WHERE page_id IN (SELECT target_id FROM #query2)) ',"
                       @"}", down_t, upper_t];
    
    
    
    // Set up the query parameter
    NSDictionary *queryParam =
    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    
    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    postRequest.session = FBSession.activeSession;
    
    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {
            iterations++;
            [self buildArrays:[result objectForKey:@"data"]];
            
            [self buildResultArray];
            NSLog(@"end query %@", [NSDate date]);
            //[TestFlight passCheckpoint:[NSString stringWithFormat:@"end facebook query %@", [NSDate date]]];
            
            if(completionBlock)
            {
                completionBlock(YES, nil);
            }
        }
        else
        {
            NSLog(@"error: %@", [error description]);
            if(completionBlock)
            {
                completionBlock(NO, error);
            }
        }
    }];
}

-(void)facebookQueryWithTimePagingRecent:(long)offset completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    NSLog(@"step recursiveQuery %i", iterations);
    
    [_checkins removeAllObjects];
    [_places removeAllObjects];
    _stringFriendsCheckins = @"";
    
    long millis = [[NSDate date] timeIntervalSince1970];
    long down_t = millis - offset;
    long upper_t = millis;
    NSLog(@"facebookQueryWithTimePagingRecent period: %li   %li   , current time %li", down_t, upper_t, upper_t - down_t);
    NSString *query = [NSString stringWithFormat:
                       @"{"
                       @"'query2':'SELECT coords, author_uid, target_id, checkin_id FROM checkin WHERE author_uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) AND timestamp > %li AND timestamp < %li',"
                       @"'query3':'select page_id, name, type, food_styles, hours, location, categories, "
                       "phone, pic, price_range, website, pic_big "
                       "from page where type in (\"RESTAURANT/CAFE\", \"BAR\", \"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, name, "
                       "type FROM place WHERE page_id IN (SELECT target_id FROM #query2)) ',"
                       @"}", down_t, upper_t];
    
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"facebookQueryWithTimePagingRecent period: %li   %li   , current time %li,  for user:  %@", down_t, upper_t, upper_t - down_t, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];

    
    // Set up the query parameter
    NSDictionary *queryParam =
    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    
    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    postRequest.session = FBSession.activeSession;
    
    
    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {
            
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"facebookQueryWithTimePagingRecent data received for user:  %@",[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];

            
            iterations++;
            [self buildArrays:[result objectForKey:@"data"]];
            
            [self buildResultArray];
            NSLog(@"end query %@", [NSDate date]);
            //[TestFlight passCheckpoint:[NSString stringWithFormat:@"end facebook query %@", [NSDate date]]];
            
            if(completionBlock)
            {
                completionBlock(YES, nil);
            }
        }
        else
        {
            NSLog(@"error: %@", [error description]);
            
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"facebookQueryWithTimePagingRecent data error:  %@ for user:  %@  ",  error.localizedDescription, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];

            
            if(completionBlock)
            {
                completionBlock(NO, error);
            }
        }
    }];
}




-(void)getFacebookQueryWithTimePaging:(RCCompleteBlockWithResult)completionBlock
{
    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;
    
    iterations = 1;
    maxIterations = 4;

    NSLog(@"start query %@", [NSDate date]);
    
    [self recursiveFacebookQueryWithTimePaging:iterations * period completionBlock:completeBlockWithResult];
    
}

-(void)getFacebookQuery:(RCCompleteBlockWithResult)completionBlock
{

    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    iterations = 0;
    maxIterations = 3;
    NSLog(@"start query %@", [NSDate date]);
    //[TestFlight passCheckpoint:[NSString stringWithFormat:@"start facebook query %@", [NSDate date]]];

    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    friendsRequest.session = FBSession.activeSession;

    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
            NSDictionary* result,
            NSError *error) {
        _friends = [result objectForKey:@"data"];
        _friendsCount = _friends.count;
        NSLog(@"Found: %i friends", _friends.count);
        //NSLog(@"friends: %@", result);
        maxIterations = _friends.count / 300;

        //[self getFacebookUserCheckins:^(BOOL res, NSError *error) {
            //if(res)
            //{
                if(_friends.count > 300)
                {
                    [self recursiveQuery:iterations * 300 completionBlock:completeBlockWithResult];
                }
                else
                {
                    NSString *query =
                            @"{"
                                    @"'query1':'SELECT uid2 FROM friend WHERE uid1 = me()',"
                                    @"'query2':'SELECT coords, author_uid, page_id, checkin_id FROM checkin WHERE author_uid IN (SELECT uid2 FROM #query1)',"
                                    @"'query3':'select page_id, name, type, food_styles, hours, location, categories, "
                                    "phone, pic, price_range, website "
                                    "from page where type in (\"RESTAURANT/CAFE\", \"BAR\", \"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, name, "
                                    "type FROM place WHERE page_id IN (SELECT page_id FROM #query2)) ',"
                                    @"}";

                    // Set up the query parameter
                    NSDictionary *queryParam =
                            [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
                    // Make the API request that uses FQL

                    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
                    postRequest.session = FBSession.activeSession;

                    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if(!error)
                        {
                           // NSLog(@"getFacebookQuery < 300 : %@", [result objectForKey:@"data"]);
                            NSLog(@"end query %@", [NSDate date]);
                           // [TestFlight passCheckpoint:[NSString stringWithFormat:@"end facebook query %@", [NSDate date]]];

                            [self buildArrays:[result objectForKey:@"data"]];
                            [self buildResult];

                            if(completeBlockWithResult)
                            {
                                completeBlockWithResult(YES, nil);
                            }

                        }
                        else
                        {
                            NSLog(@"error: %@", [error description]);
                            if(completeBlockWithResult)
                            {
                                completeBlockWithResult(NO, error);
                            }
                        }
                    }];
                }
           // }
        //}];

    }];

}

-(void)getFacebookQueryRecent:(NSDate *)lastDate  completionBlock:(RCCompleteBlockWithResult)completionBlock
{


    long millis = [lastDate timeIntervalSince1970];

    //millis = 1349845200;
    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    iterations = 0;
    maxIterations = 3;
    NSLog(@"start query %@", [NSDate date]);


   /* FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    friendsRequest.session = FBSession.activeSession;

    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
            NSDictionary* result,
            NSError *error) {
        _friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", _friends.count);
        //NSLog(@"friends: %@", result);
        maxIterations = _friends.count / 300;
*/
        [self getFacebookUserCheckinsRecent:millis completionBlock:^(BOOL res, NSError *error) {
            if(res)
            {
               /* if(_friends.count > 300)
                {
                    [self recursiveQuery:iterations * 300 completionBlock:completeBlockWithResult];
                }
                else
                {*/
                    NSString *query =
                    [NSString stringWithFormat:
                    @"{"
                                    @"'query1':'SELECT uid2 FROM friend WHERE uid1 = me()',"
                                    @"'query2':'SELECT coords, author_uid, page_id, checkin_id FROM checkin WHERE author_uid IN (SELECT uid2 FROM #query1) AND timestamp > %li',"
                            @"'query3':'select page_id, name, type, food_styles, hours, location, categories, "
                            "phone, pic, price_range, website "
                            "from page where type in (\"RESTAURANT/CAFE\", \"BAR\", \"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, "
                            "name FROM place WHERE page_id IN (SELECT page_id FROM #query2))',"
                                    @"}", millis];
                    NSLog(@"query: %@", query);
                    // Set up the query parameter
                    NSDictionary *queryParam =
                            [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
                    // Make the API request that uses FQL

                    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
                    postRequest.session = FBSession.activeSession;

                    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if(!error)
                        {
                            //NSLog(@"getFacebookQuery < 300 : %@", [result objectForKey:@"data"]);
                            NSLog(@"end query %@", [NSDate date]);
                            [self buildArrays:[result objectForKey:@"data"]];
                            [self buildResult];

                            if(completeBlockWithResult)
                            {
                                completeBlockWithResult(YES, nil);
                            }

                        }
                        else
                        {
                            NSLog(@"error: %@", [error description]);
                            if(completeBlockWithResult)
                            {
                                completeBlockWithResult(NO, error);
                            }
                        }
                    }];
                //}
            }
        }];

   // }];

}


-(void)buildArrays:(NSDictionary *)dict
{


    for(NSDictionary *sub in dict)
    {
        if([[sub objectForKey:@"name"] isEqualToString:@"query2"])
        {
            [_checkins addObjectsFromArray:[sub objectForKey:@"fql_result_set"]];
        }
        if([[sub objectForKey:@"name"] isEqualToString:@"query3"])
        {
            [_places addObjectsFromArray:[sub objectForKey:@"fql_result_set"]];
        }
    }

    NSLog(@"result arrays checkins: %i   places: %i", _checkins.count, _places.count);


}

-(void)buildArraysForUser:(NSDictionary *)dict
{


    for(NSDictionary *sub in dict)
    {
        if([[sub objectForKey:@"name"] isEqualToString:@"query1"])
        {
            [_userCheckins addObjectsFromArray:[sub objectForKey:@"fql_result_set"]];
        }
        if([[sub objectForKey:@"name"] isEqualToString:@"query2"])
        {
            [_userPlaces addObjectsFromArray:[sub objectForKey:@"fql_result_set"]];
        }
    }

    NSLog(@"result user arrays :%i   %i", _userCheckins.count, _userPlaces.count);


}


-(NSString *)getPlaceNameFromPlaceId:(id)placeId
{
    for(NSDictionary *place in _places)
    {
        if([[place objectForKey:@"page_id"] isEqual:placeId])
        {
            return [place objectForKey:@"name"];
        }
    }
    return @"";
}

-(NSString *)getPlaceNameFromPlaceIdForUser:(id)placeId
{
    for(NSDictionary *place in _userPlaces)
    {
        if([[place objectForKey:@"page_id"] isEqual:placeId])
        {
            return [place objectForKey:@"name"];
        }
    }
    return @"";
}



-(void)buildResult
{
    NSMutableArray *temp = [NSMutableArray new];
    if(_checkins.count == 0)
    {
        _stringFriendsCheckins = nil;
        return;
    }

    NSLog(@"friends checkins total count: %i", _checkins.count);
   // int i = 0;
    for(NSMutableDictionary *checkin in _checkins)
    {
        //NSLog(@"%@", checkin);

        NSDictionary *placeDict = [self getFriendPageIsFromCheckins:[checkin objectForKey:@"target_id"]];
        //NSLog(@"%@", placeDict);
        if(placeDict)
        {
            if([[checkin objectForKey:@"coords"] isKindOfClass:[NSDictionary class]])
            {
                NSString *placeName = [self getPlaceNameFromPlaceId:[checkin objectForKey:@"target_id"]];
                //NSLog(@"%@", placeName);
                placeName = [placeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"'" withString:@""];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"&" withString:@""];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"," withString:@""];

                placeName = [self stringWithPercentEscape:placeName];
                


                NSArray *locArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue:@"latitude" value:[[checkin objectForKey:@"coords"] objectForKey:@"latitude"]],
                                                              [self makeStringWithKeyAndValue:@"longitude" value:[[checkin objectForKey:@"coords"] objectForKey:@"longitude"]],
                                                              nil];

                NSArray *friendCheckinArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"author_uid" value:[checkin objectForKey:@"author_uid"]],
                                                                        [self makeStringWithKeyAndValue2:@"checkin_id" value:[checkin objectForKey:@"checkin_id"]],
                                                                        [self makeStringWithKeyAndValue:@"name" value:placeName],
                                                                        [self makeStringWithKeyAndValue2:@"page_id" value:[checkin objectForKey:@"target_id"]],
                                                                        [self makeStringWithKeyAndValue2:@"coords" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                                                        nil];

                //place dictionary building
                NSMutableArray *foodStyles = [NSMutableArray new];
                for(NSString *style in [placeDict objectForKey:@"food_styles"])
                {
                    NSString *s = [style stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    s = [s stringByReplacingOccurrencesOfString:@"&" withString:@""];
                    s = [s stringByReplacingOccurrencesOfString:@"/" withString:@""];


                    
                    [foodStyles addObject:s];
                }
                NSString *foodStyleString = [NSString stringWithFormat:@"\"food_styles\":\"%@\"", [foodStyles componentsJoinedByString:@","]];

                
                NSMutableArray *categories = [NSMutableArray new];
                for(NSDictionary *cat in [placeDict objectForKey:@"categories"])
                {
                    [categories addObject:[[cat objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"&" withString:@""]];
                }
                NSString *categoriesString = [NSString stringWithFormat:@"%@", [categories componentsJoinedByString:@","]];

                NSMutableArray *hours = [NSMutableArray new];
                NSString *hoursString = @"\"hours\":{}";
                if([((NSDictionary *) [placeDict objectForKey:@"hours"]) respondsToSelector:@selector(allKeys)])
                {
                    for(NSString *hour in ((NSDictionary *)[placeDict objectForKey:@"hours"]).allKeys)
                    {
                        [hours addObject:[self makeStringWithKeyAndValue:hour value:[((NSDictionary *)[placeDict objectForKey:@"hours"]) objectForKey:hour]]];
                    }
                }
                hoursString = [NSString stringWithFormat:@"\"hours\":{%@}", [hours componentsJoinedByString:@","]];

                NSString *phone = [placeDict objectForKey:@"phone"] == [NSNull null] ? @"" : [[placeDict objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@"&" withString:@"" ];
                NSString *street = [[placeDict objectForKey:@"location"] objectForKey:@"street"] == [NSNull null] ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"street"];

                NSArray *placeArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"id" value:[checkin objectForKey:@"target_id"]],
                                                                [self makeStringWithKeyAndValue2:@"location" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                                                [self makeStringWithKeyAndValue:@"name" value:placeName],
                                                                [self makeStringWithKeyAndValue:@"city" value:[[placeDict objectForKey:@"location"] objectForKey:@"city"]],
                                                                [self makeStringWithKeyAndValue:@"country" value:[[placeDict objectForKey:@"location"] objectForKey:@"country"]],
                                                                [self makeStringWithKeyAndValue:@"state" value:[[placeDict objectForKey:@"location"] objectForKey:@"state"]],
                                       [self makeStringWithKeyAndValue:@"street" value:[self stringWithPercentEscape:[street stringByReplacingOccurrencesOfString:@"\"" withString:@""]]],

                                                                [self makeStringWithKeyAndValue:@"zip" value:[[placeDict objectForKey:@"location"] objectForKey:@"zip"]],
                                                                [self makeStringWithKeyAndValue:@"phone" value:phone],
                                [self makeStringWithKeyAndValue:@"type" value:categoriesString],
                                       [self makeStringWithKeyAndValue:@"pic" value:[self stringWithPercentEscape:[placeDict objectForKey:@"pic_big"]]],

                                [self makeStringWithKeyAndValue:@"price_range" value:[placeDict objectForKey:@"price_range"]],
                                //[self makeStringWithKeyAndValue:@"website" value:[self stringWithPercentEscape:[placeDict objectForKey:@"website"]]],
                                //hoursString,
                                                                foodStyleString,

                                                                nil];
                NSString *place = [NSString stringWithFormat:@"\"place\":{%@}", [placeArray componentsJoinedByString:@","]];







                NSString *item = [NSString stringWithFormat:@"{%@,%@}", [friendCheckinArray componentsJoinedByString:@","], place];


               // NSLog(@"%@", item);

                //NSLog(@"%@", placeName);
                //[checkin setObject:placeName forKey:@"name"];
                [temp addObject:item];
                
                
               /* i++;
                
                if(i >= 500)
                {
                    NSString *dataTemp = [NSString stringWithFormat:@"fb_usercheckin={\"data\":[%@]}",[temp componentsJoinedByString:@","]];
                    [_friendsCheckinsArray addObject:dataTemp];
                }*/
                
            }
        }






    }

    //NSArray *tt = [temp objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 500)]];
    
    
    
    //NSString *data = [NSString stringWithFormat:@"fb_usercheckin={\"data\":[%@]}",[temp componentsJoinedByString:@","]];
    NSString *data = [NSString stringWithFormat:@"[%@]",[temp componentsJoinedByString:@","]];

    
    //NSLog(@"result for friends send count %i:  data: %@ ", temp.count, data);
    NSLog(@"result for friends send count %i", temp.count);

    //_stringFriendsCheckins = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _stringFriendsCheckins = data;

}


-(void)buildResultArray
{
    NSMutableArray *temp = [NSMutableArray new];
    if(_checkins.count == 0)
    {
        _friendsCheckinsArray = nil;
        return;
    }
    [_friendsCheckinsArray removeAllObjects];
    NSLog(@"friends checkins total count: %i", _checkins.count);
    // int i = 0;
    for(NSMutableDictionary *checkin in _checkins)
    {
        //NSLog(@"%@", checkin);
        
        NSDictionary *placeDict = [self getFriendPageIsFromCheckins:[checkin objectForKey:@"target_id"]];
        //NSLog(@"%@", placeDict);
        if(placeDict)
        {
            if([[checkin objectForKey:@"coords"] isKindOfClass:[NSDictionary class]])
            {
                NSString *placeName = [self getPlaceNameFromPlaceId:[checkin objectForKey:@"target_id"]];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"'" withString:@""];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"&" withString:@""];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"," withString:@""];
                
                placeName = [self stringWithPercentEscape:placeName];
                
                
                
                NSDictionary *locArray = @{@"latitude":[[checkin objectForKey:@"coords"] objectForKey:@"latitude"],
                                     @"longitude":[[checkin objectForKey:@"coords"] objectForKey:@"longitude"]
                                           };
                

                NSMutableArray *foodStyles = [NSMutableArray new];
                for(NSString *style in [placeDict objectForKey:@"food_styles"])
                {
                    NSString *s = [style stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    s = [s stringByReplacingOccurrencesOfString:@"&" withString:@""];
                    s = [s stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    
                    
                    
                    [foodStyles addObject:s];
                }
                //NSString *foodStylesStr = [foodStyles componentsJoinedByString:@","];
                
                NSMutableArray *categories = [NSMutableArray new];
                for(NSDictionary *cat in [placeDict objectForKey:@"categories"])
                {
                    [categories addObject:[[cat objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"&" withString:@""]];
                }
                NSString *categoriesString = [NSString stringWithFormat:@"%@", [categories componentsJoinedByString:@","]];
                
                NSMutableArray *hours = [NSMutableArray new];
                NSDictionary *hoursString = @{@"hours":@""};
                if([((NSDictionary *) [placeDict objectForKey:@"hours"]) respondsToSelector:@selector(allKeys)])
                {
                    for(NSString *hour in ((NSDictionary *)[placeDict objectForKey:@"hours"]).allKeys)
                    {
                        [hours addObject:[self makeStringWithKeyAndValue:hour value:[((NSDictionary *)[placeDict objectForKey:@"hours"]) objectForKey:hour]]];
                    }
                }
                hoursString = @{@"hours":hours};
                
                NSString *phone = [placeDict objectForKey:@"phone"] == [NSNull null] ? @"" : [[placeDict objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@"&" withString:@"" ];
                NSString *street = [[placeDict objectForKey:@"location"] objectForKey:@"street"] == [NSNull null] ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"street"];
                
                NSDictionary *placeArray = @{@"id":[checkin objectForKey:@"target_id"],
                                       @"location":locArray,
                                       @"name":placeName,
                                             @"city":[[placeDict objectForKey:@"location"] objectForKey:@"city"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"city"],
                                             @"country":[[placeDict objectForKey:@"location"] objectForKey:@"country"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"country"],
                                             @"state":[[placeDict objectForKey:@"location"] objectForKey:@"state"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"state"],
                                       @"street":[self stringWithPercentEscape:[street stringByReplacingOccurrencesOfString:@"\"" withString:@""]],
                                       
                                             @"zip":[[placeDict objectForKey:@"location"] objectForKey:@"zip"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"zip"],
                                       @"phone":phone,
                                       @"type":categoriesString,
                                             @"pic":[placeDict objectForKey:@"pic_big"] == nil ? @"" : [self stringWithPercentEscape:[placeDict objectForKey:@"pic_big"]],
                                       
                                             @"price_range":[placeDict objectForKey:@"price_range"] == nil ? @"" : [placeDict objectForKey:@"price_range"],

                                       @"food_styles":[foodStyles componentsJoinedByString:@","]
                                       
                                             };

                NSDictionary *item = @{@"author_uid":[checkin objectForKey:@"author_uid"],
                                         @"checkin_id":[checkin objectForKey:@"checkin_id"],
                                       
                                         @"coords":locArray,
                                        @"name":placeName,
                                       @"page_id":[checkin objectForKey:@"target_id"],

                                       @"place":placeArray};
                

                [temp addObject:item];
                
               
                
            }
        }

        
    }

    
    NSLog(@"result for friends send count %i", temp.count);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:temp options:NSJSONWritingPrettyPrinted error:nil ];
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"result for friends : %@", aStr);
    //_stringFriendsCheckins = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _friendsCheckinsArray = temp;
    
}


-(NSDictionary *)getUserPageIsFromCheckins:(NSString *)pageId
{
    for(NSDictionary *place in _userPlaces)
    {
        if([[place objectForKey:@"page_id"] isEqual:pageId])
        {
            return place;
        }
    }
    return nil;
}


-(NSDictionary *)getFriendPageIsFromCheckins:(NSString *)pageId
{
    for(NSDictionary *place in _places)
    {
        if([[place objectForKey:@"page_id"] isEqual:pageId])
        {
            return place;
        }
    }
    return nil;
}

-(NSString*)stringWithPercentEscape:(NSString *)str {
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[str mutableCopy], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8));
}


-(void)buildResultForUser
{
    
    NSMutableArray *temp = [NSMutableArray new];
    if(_userCheckins.count == 0)
    {
        _stringUserCheckins = nil;
        return;
    }
    for(NSMutableDictionary *checkin in _userCheckins)
    {
        //NSLog(@"%@", checkin);
        
        NSDictionary *placeDict = [self getUserPageIsFromCheckins:[checkin objectForKey:@"target_id"]];
        //NSLog(@"%@", placeDict);
        if(placeDict)
        {
            NSString *placeName = [placeDict objectForKey:@"name"];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"'" withString:@""];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            placeName = [self stringWithPercentEscape:placeName];
            
            
            NSArray *fromArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"id" value:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId]],
                                  [self makeStringWithKeyAndValue:@"name" value:[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookName]],
                                  nil];
            NSString *from = [NSString stringWithFormat:@"\"from\":{%@}", [fromArray componentsJoinedByString:@","]];
            
            
            NSArray *locArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue:@"latitude" value:[[checkin objectForKey:@"coords"] objectForKey:@"latitude"]],
                                 [self makeStringWithKeyAndValue:@"longitude" value:[[checkin objectForKey:@"coords"] objectForKey:@"longitude"]],
                                 nil];
            
            //place dictionary building
            NSMutableArray *foodStyles = [NSMutableArray new];
            for(NSString *style in [placeDict objectForKey:@"food_styles"])
            {
                [foodStyles addObject:style];
            }
            NSString *foodStyleString = [NSString stringWithFormat:@"\"food_styles\":\"%@\"", [foodStyles componentsJoinedByString:@","]];
            
            //place dictionary building
            NSMutableArray *categories = [NSMutableArray new];
            for(NSDictionary *cat in [placeDict objectForKey:@"categories"])
            {
                [categories addObject:[[cat objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"&" withString:@""]];
            }
            NSString *categoriesString = [NSString stringWithFormat:@"%@", [categories componentsJoinedByString:@","]];
            
            
            NSMutableArray *hours = [NSMutableArray new];
            NSString *hoursString = @"\"hours\":{}";
            if([((NSDictionary *) [placeDict objectForKey:@"hours"]) respondsToSelector:@selector(allKeys)])
            {
                for(NSString *hour in ((NSDictionary *)[placeDict objectForKey:@"hours"]).allKeys)
                {
                    [hours addObject:[self makeStringWithKeyAndValue:hour value:[((NSDictionary *)[placeDict objectForKey:@"hours"]) objectForKey:hour]]];
                }
            }
            hoursString = [NSString stringWithFormat:@"\"hours\":{%@}", [hours componentsJoinedByString:@","]];
            
            NSArray *placeArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"id" value:[checkin objectForKey:@"target_id"]],
                                   [self makeStringWithKeyAndValue2:@"location" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                   [self makeStringWithKeyAndValue:@"name" value:placeName],
                                   [self makeStringWithKeyAndValue:@"city" value:[[placeDict objectForKey:@"location"] objectForKey:@"city"]],
                                   [self makeStringWithKeyAndValue:@"country" value:[[placeDict objectForKey:@"location"] objectForKey:@"country"]],
                                   [self makeStringWithKeyAndValue:@"state" value:[[placeDict objectForKey:@"location"] objectForKey:@"state"]],
                                   [self makeStringWithKeyAndValue:@"street" value:[self stringWithPercentEscape:[[[placeDict objectForKey:@"location"] objectForKey:@"street"] stringByReplacingOccurrencesOfString:@"\"" withString:@""]]],
                                   [self makeStringWithKeyAndValue:@"zip" value:[[placeDict objectForKey:@"location"] objectForKey:@"zip"]],
                                   [self makeStringWithKeyAndValue:@"phone" value:[placeDict objectForKey:@"phone"]],
                                   [self makeStringWithKeyAndValue:@"type" value:categoriesString],
                                   [self makeStringWithKeyAndValue:@"pic" value:[self stringWithPercentEscape:[placeDict objectForKey:@"pic_big"]]],
                                   [self makeStringWithKeyAndValue:@"price_range" value:[placeDict objectForKey:@"price_range"]],
                                   //[self makeStringWithKeyAndValue:@"website" value:[self stringWithPercentEscape:[placeDict objectForKey:@"website"]]],
                                   //hoursString,
                                   foodStyleString,
                                   
                                   nil];
            NSString *place = [NSString stringWithFormat:@"\"place\":{%@}", [placeArray componentsJoinedByString:@","]];
            
            
            NSString *item = [NSString stringWithFormat:@"{%@,%@,%@}", from, [self makeStringWithKeyAndValue2:@"id" value:[checkin objectForKey:@"checkin_id"]], place];
            
            /*NSDictionary *resCheck = @{@"id": [checkin objectForKey:@"checkin_id"],
             @"from": @{@"name": [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookName],
             @"id": [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId]},
             @"place": @{@"id": [checkin objectForKey:@"page_id"],
             @"name": placeName,
             @"location": @{@"latitude": [[checkin objectForKey:@"coords"] objectForKey:@"latitude"],
             @"longitude": [[checkin objectForKey:@"coords"] objectForKey:@"longitude"]}
             
             }
             
             };*/
            
            
            
            //NSLog(@"%@", item);
            
            //NSLog(@"%@", placeName);
            //[checkin setObject:placeName forKey:@"name"];
            [temp addObject:item];
        }
        
        
        
    }
    
    //NSString *data = [NSString stringWithFormat:@"fb_usercheckin={\"data\":[%@]}",[temp componentsJoinedByString:@","]];
    NSString *data = [NSString stringWithFormat:@"[%@]",[temp componentsJoinedByString:@","]];
    
    
    NSLog(@"result for user checkins %i, data:  %@", temp.count, data);
    //_stringUserCheckins = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _stringUserCheckins = data;
    
    //_resultUserCheckins = @{@"fb_usercheckin" : [NSMutableDictionary dictionaryWithObject:temp forKey:@"data"]};
}



-(void)buildResultForUserDict
{

    NSMutableArray *temp = [NSMutableArray new];
    if(_userCheckins.count == 0)
    {
        _userCheckinsArray = nil;
        return;
    }
    [_userCheckinsArray removeAllObjects];
    for(NSMutableDictionary *checkin in _userCheckins)
    {
        //NSLog(@"%@", checkin);

        NSDictionary *placeDict = [self getUserPageIsFromCheckins:[checkin objectForKey:@"target_id"]];
        //NSLog(@"%@", placeDict);
        if(placeDict)
        {
            NSString *placeName = [placeDict objectForKey:@"name"];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"'" withString:@""];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"," withString:@""];

            placeName = [self stringWithPercentEscape:placeName];


            NSDictionary *fromArray = @{@"id":[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookId],
                                                            @"name":[[NSUserDefaults standardUserDefaults] objectForKey:kRCUserFacebookName]
                                        };


            NSDictionary *locArray = @{@"latitude":[[checkin objectForKey:@"coords"] objectForKey:@"latitude"],
                                                        @"longitude":[[checkin objectForKey:@"coords"] objectForKey:@"longitude"]
                                       };

           //place dictionary building
            NSMutableArray *foodStyles = [NSMutableArray new];
            for(NSString *style in [placeDict objectForKey:@"food_styles"])
            {
                [foodStyles addObject:style];
            }

            //place dictionary building
            NSMutableArray *categories = [NSMutableArray new];
            for(NSDictionary *cat in [placeDict objectForKey:@"categories"])
            {
                [categories addObject:[[cat objectForKey:@"name"] stringByReplacingOccurrencesOfString:@"&" withString:@""]];
            }
            NSString *categoriesString = [NSString stringWithFormat:@"%@", [categories componentsJoinedByString:@","]];
            
            
            NSMutableArray *hours = [NSMutableArray new];
            NSDictionary *hoursString = @{@"hours":@""};
            if([((NSDictionary *) [placeDict objectForKey:@"hours"]) respondsToSelector:@selector(allKeys)])
            {
                for(NSString *hour in ((NSDictionary *)[placeDict objectForKey:@"hours"]).allKeys)
                {
                    [hours addObject:[self makeStringWithKeyAndValue:hour value:[((NSDictionary *)[placeDict objectForKey:@"hours"]) objectForKey:hour]]];
                }
            }
            hoursString = @{@"hours":hours};

            NSDictionary *placeArray = @{@"id":[checkin objectForKey:@"target_id"],
                                                   @"location":locArray,
                                                   @"name":placeName,
                                                   @"city":[[placeDict objectForKey:@"location"] objectForKey:@"city"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"city"],
                                                   @"country":[[placeDict objectForKey:@"location"] objectForKey:@"country"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"country"],
                                                   @"state":[[placeDict objectForKey:@"location"] objectForKey:@"state"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"state"],
                                                   @"street":[[placeDict objectForKey:@"location"] objectForKey:@"street"] == nil ? @"" : [self stringWithPercentEscape:[[[placeDict objectForKey:@"location"] objectForKey:@"street"] stringByReplacingOccurrencesOfString:@"\"" withString:@""]],
                                                   @"zip":[[placeDict objectForKey:@"location"] objectForKey:@"zip"] == nil ? @"" : [[placeDict objectForKey:@"location"] objectForKey:@"zip"],
                                                   @"phone":[placeDict objectForKey:@"phone"] == nil ? @"" : [placeDict objectForKey:@"phone"],
                                                   @"type":categoriesString,
                                                   @"pic":[placeDict objectForKey:@"pic_big"] == nil ? @"" : [self stringWithPercentEscape:[placeDict objectForKey:@"pic_big"]],
                                                   @"price_range":[placeDict objectForKey:@"price_range"] == nil ? @"" : [placeDict objectForKey:@"price_range"],
                            //[self makeStringWithKeyAndValue:@"website" value:[self stringWithPercentEscape:[placeDict objectForKey:@"website"]]],
                            //hoursString,
                            @"food_styles":[foodStyles componentsJoinedByString:@","]

                                         };


            NSDictionary *item = @{@"from":fromArray,@"id":[checkin objectForKey:@"checkin_id"], @"place":placeArray};


            [temp addObject:item];
        }



    }

    NSLog(@"result for user checkins %i, data:  %@", temp.count, temp);
    //_stringUserCheckins = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    _userCheckinsArray = temp;

    //_resultUserCheckins = @{@"fb_usercheckin" : [NSMutableDictionary dictionaryWithObject:temp forKey:@"data"]};
}


-(NSString *)makeStringWithKeyAndValue:(NSString *)key value:(NSString *)value
{

    return [NSString stringWithFormat:@"\"%@\":\"%@\"", key, value];



}

-(NSString *)makeStringWithKeyAndValue2:(NSString *)key value:(NSString *)value
{

    return [NSString stringWithFormat:@"\"%@\":%@", key, value];



}

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
                ^(FBRequestConnection *connection,
                        NSDictionary<FBGraphUser> *user,
                        NSError *error) {
                    if (!error) {
                        _userName = user.name;
                    }
                }];
    }
}

-(void)getFacebookUserCheckinsRecent2:(long)offset  completionBlock:(RCCompleteBlockWithResult)completionBlock
{
    
    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;
    
    long millis = [[NSDate date] timeIntervalSince1970];
    long down_t = millis - offset;
    long upper_t = millis;
    
    int numberOfDays = offset / 86400;
    if(numberOfDays < 10)
    {
        down_t = millis - (86400 * 10);
    }
    NSLog(@"getFacebookUserCheckinsRecent2 period: %li   %li   , current time %li, numberOfDays %i", down_t, upper_t, upper_t - down_t, numberOfDays);

    [TestFlight passCheckpoint:[NSString stringWithFormat:@"getFacebookUserCheckinsRecent2 period: %li   %li   , current time %li, numberOfDays %i for user:  %@", down_t, upper_t, upper_t - down_t, numberOfDays, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];
    
    
    NSString *query = [NSString stringWithFormat:
                       @"{"
                       @"'query1':'SELECT coords, author_uid, target_id, checkin_id FROM checkin WHERE author_uid = me() AND timestamp > %li AND timestamp < %li',"
                       @"'query2':'select page_id, name, type, food_styles, hours, location, categories, "
                       "phone, pic, price_range, website, pic_big "
                       "from page where page_id in (SELECT page_id, "
                       "name, type "
                       " FROM place WHERE page_id IN (SELECT target_id FROM #query1))',"
                       @"}", down_t, upper_t];
    
    // Set up the query parameter
    NSDictionary *queryParam =
    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    // Make the API request that uses FQL
    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    postRequest.session = FBSession.activeSession;
    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"getFacebookUserCheckinsRecent2 data received for user %@", [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];

            NSLog(@"user checkins result: %@", [result objectForKey:@"data"]);
            [self buildArraysForUser:[result objectForKey:@"data"]];
            [self buildResultForUserDict];
            if(completeBlockWithResult)
            {
                completeBlockWithResult(YES, nil);
            }
            
        }
        else
        {
            
            NSLog(@"error: %@", [error description]);
            
            [TestFlight passCheckpoint:[NSString stringWithFormat:@"getFacebookUserCheckinsRecent2 data error:  %@ for user:  %@  ",  error.localizedDescription, [[NSUserDefaults standardUserDefaults] objectForKey:kRCUserId]]];

            
            if(completeBlockWithResult)
            {
                completeBlockWithResult(NO, error);
            }
        }
    }];
    

}


-(void)getFacebookUserCheckins:(RCCompleteBlockWithResult)completionBlock
{

        RCCompleteBlockWithResult completeBlockWithResult = completionBlock;
    
    
        NSString *query = [NSString stringWithFormat:
                           @"{"
                           @"'query1':'SELECT coords, author_uid, target_id, checkin_id FROM checkin WHERE author_uid = me() limit 0, 100',"
                           @"'query2':'select page_id, name, type, food_styles, hours, location, categories, "
                           "phone, pic, price_range, website, pic_big "
                           "from page where type in (\"RESTAURANT/CAFE\", "
                           "\"BAR\", "
                           "\"HOTEL\", \"LOCAL BUSINESS\", \"PLACE\") and page_id in (SELECT page_id, "
                           "name, type "
                           " FROM place WHERE page_id IN (SELECT target_id FROM #query1))',"
                           @"}"];
        
        // Set up the query parameter
        NSDictionary *queryParam =
        [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
        // Make the API request that uses FQL
        FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
        postRequest.session = FBSession.activeSession;
        [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error)
            {
                NSLog(@"user checkins result: %@", [result objectForKey:@"data"]);
                [self buildArraysForUser:[result objectForKey:@"data"]];
                [self buildResultForUserDict];
                if(completeBlockWithResult)
                {
                    completeBlockWithResult(YES, nil);
                }
                
            }
            else
            {
                
                NSLog(@"error: %@", [error description]);
                
                
                if(completeBlockWithResult)
                {
                    completeBlockWithResult(NO, error);
                }
            }
        }];

    

    

    
}

-(void)getFacebookUserCheckinsRecent:(int)millis completionBlock:(RCCompleteBlockWithResult)completionBlock
{

    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    NSString *query = [NSString stringWithFormat:
            @"{"
                    @"'query1':'SELECT coords, author_uid, page_id, checkin_id FROM checkin WHERE author_uid = me() AND timestamp > %i',"
                    @"'query2':'select page_id, name, type, food_styles, hours, location,  "
                    "phone, pic, price_range, website "
                    "from page where type in (\"RESTAURANT/CAFE\", \"BAR\", \"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, "
                    "name FROM place WHERE page_id IN (SELECT page_id FROM #query1))',"
                    @"}", millis];

    // Set up the query parameter
    NSDictionary *queryParam =
            [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    // Make the API request that uses FQL
    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"/fql" parameters:queryParam HTTPMethod:@"GET"];
    postRequest.session = FBSession.activeSession;
    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {

            [self buildArraysForUser:[result objectForKey:@"data"]];
            [self buildResultForUser];
            if(completeBlockWithResult)
            {
                completeBlockWithResult(YES, nil);
            }

        }
        else
        {

            NSLog(@"error: %@", [error description]);
            if(completeBlockWithResult)
            {
                completeBlockWithResult(NO, error);
            }
        }
    }];
}



-(void)getFacebookMe {


    FBRequest *postRequest = [FBRequest requestForGraphPath:@"me"];
    postRequest.session = FBSession.activeSession;


    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {
            NSLog(@"getFacebookMe: %@", [result objectForKey:@"data"]);

        }
        else
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];

}

-(void)getFacebookRecentCheckins {

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            @"checkin",@"type",nil];

    FBRequest *postRequest = [FBRequest requestWithGraphPath:@"search" parameters:params HTTPMethod:@"GET"];
    postRequest.session = FBSession.activeSession;


    [postRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error)
        {
            NSLog(@"getFacebookRecentCheckins: %@", [result objectForKey:@"data"]);

        }
        else
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];

}

-(void)getFacebookFriends
{

    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    friendsRequest.session = FBSession.activeSession;

    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
            NSDictionary* result,
            NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        NSLog(@"friends: %@", result);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        }
    }];
}










- (id)init {
    self = [super init];


    _checkins = [NSMutableArray new];
    _places = [NSMutableArray new];
    _userCheckins = [NSMutableArray new];
    _userPlaces = [NSMutableArray new];
    _friends = [NSArray new];
    _friendsCheckinsArray = [NSMutableArray new];
    //eriod = 31536000;
    period = 15768000;

#if !(TARGET_IPHONE_SIMULATOR)


#else


#endif

    return self;

}



+(id)sharedInstance
{
    static dispatch_once_t pred;
    static facebookHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[facebookHelper alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc
{

    abort();
}


@end