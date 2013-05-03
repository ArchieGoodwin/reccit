//
// Created by sdikarev on 4/11/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "facebookHelper.h"
#import "RCDefine.h"
#import <FacebookSDK/FacebookSDK.h>


@implementation facebookHelper {
    int iterations;
    int maxIterations;
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

-(void)getFacebookQuery:(RCCompleteBlockWithResult)completionBlock
{

    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    iterations = 0;
    maxIterations = 3;
    NSLog(@"start query %@", [NSDate date]);


    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    friendsRequest.session = FBSession.activeSession;

    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
            NSDictionary* result,
            NSError *error) {
        _friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", _friends.count);
        //NSLog(@"friends: %@", result);
        maxIterations = _friends.count / 300;

        [self getFacebookUserCheckins:^(BOOL res, NSError *error) {
            if(res)
            {
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
            }
        }];

    }];

}

-(void)getFacebookQueryRecent:(NSDate *)lastDate  completionBlock:(RCCompleteBlockWithResult)completionBlock
{


    int millis = [lastDate timeIntervalSince1970];

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

    NSLog(@"result arrays :%i   %i", _checkins.count, _places.count);


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
    for(NSMutableDictionary *checkin in _checkins)
    {
        //NSLog(@"%@", checkin);

        NSDictionary *placeDict = [self getFriendPageIsFromCheckins:[checkin objectForKey:@"page_id"]];
        //NSLog(@"%@", placeDict);
        if(placeDict)
        {
            if([[checkin objectForKey:@"coords"] isKindOfClass:[NSDictionary class]])
            {
                NSString *placeName = [self getPlaceNameFromPlaceId:[checkin objectForKey:@"page_id"]];
                //NSLog(@"%@", placeName);
                placeName = [placeName stringByReplacingOccurrencesOfString:@"(" withString:@" "];
                placeName = [placeName stringByReplacingOccurrencesOfString:@")" withString:@" "];
                placeName = [placeName stringByReplacingOccurrencesOfString:@"&" withString:@" "];

                NSArray *locArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue:@"latitude" value:[[checkin objectForKey:@"coords"] objectForKey:@"latitude"]],
                                                              [self makeStringWithKeyAndValue:@"longitude" value:[[checkin objectForKey:@"coords"] objectForKey:@"longitude"]],
                                                              nil];

                NSArray *friendCheckinArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"author_uid" value:[checkin objectForKey:@"author_uid"]],
                                                                        [self makeStringWithKeyAndValue2:@"checkin_id" value:[checkin objectForKey:@"checkin_id"]],
                                                                        [self makeStringWithKeyAndValue:@"name" value:[placeName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                                                                        [self makeStringWithKeyAndValue2:@"page_id" value:[checkin objectForKey:@"page_id"]],
                                                                        [self makeStringWithKeyAndValue2:@"coords" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                                                        nil];

                //place dictionary building
                NSMutableArray *foodStyles = [NSMutableArray new];
                for(NSString *style in [placeDict objectForKey:@"food_styles"])
                {
                    [foodStyles addObject:style];
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

                NSArray *placeArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"id" value:[checkin objectForKey:@"page_id"]],
                                                                [self makeStringWithKeyAndValue2:@"location" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                                                [self makeStringWithKeyAndValue:@"name" value:[placeName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                                                                [self makeStringWithKeyAndValue:@"city" value:[[placeDict objectForKey:@"location"] objectForKey:@"city"]],
                                                                [self makeStringWithKeyAndValue:@"country" value:[[placeDict objectForKey:@"location"] objectForKey:@"country"]],
                                                                [self makeStringWithKeyAndValue:@"state" value:[[placeDict objectForKey:@"location"] objectForKey:@"state"]],
                                                                [self makeStringWithKeyAndValue:@"street" value:[[[[placeDict objectForKey:@"location"] objectForKey:@"street"]
                                                                        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@" "]],
                                                                [self makeStringWithKeyAndValue:@"zip" value:[[placeDict objectForKey:@"location"] objectForKey:@"zip"]],
                                                                [self makeStringWithKeyAndValue:@"phone" value:[placeDict objectForKey:@"phone"]],
                                [self makeStringWithKeyAndValue:@"type" value:categoriesString],
                        [self makeStringWithKeyAndValue:@"pic" value:[[placeDict objectForKey:@"pic"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                                                                [self makeStringWithKeyAndValue:@"price_range" value:[placeDict objectForKey:@"price_range"]],
                                [self makeStringWithKeyAndValue:@"website" value:[[[placeDict objectForKey:@"website"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                        stringByReplacingOccurrencesOfString:@"&" withString:@""]],
                                hoursString,
                                                                foodStyleString,

                                                                nil];
                NSString *place = [NSString stringWithFormat:@"\"place\":{%@}", [placeArray componentsJoinedByString:@","]];







                NSString *item = [NSString stringWithFormat:@"{%@,%@}", [friendCheckinArray componentsJoinedByString:@","], place];


               // NSLog(@"%@", item);

                //NSLog(@"%@", placeName);
                //[checkin setObject:placeName forKey:@"name"];
                [temp addObject:item];
            }
        }






    }

    NSString *data = [NSString stringWithFormat:@"fb_usercheckin={\"data\":[%@]}",[temp componentsJoinedByString:@","]];

    NSLog(@"result for friends send count %i: ", temp.count);
    _stringFriendsCheckins = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
        NSDictionary *placeDict = [self getUserPageIsFromCheckins:[checkin objectForKey:@"page_id"]];
        //NSLog(@"%@", placeDict);
        if(placeDict)
        {
            NSString *placeName = [placeDict objectForKey:@"name"];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"(" withString:@" "];
            placeName = [placeName stringByReplacingOccurrencesOfString:@")" withString:@" "];
            placeName = [placeName stringByReplacingOccurrencesOfString:@"&" withString:@" "];


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

            NSArray *placeArray = [NSArray arrayWithObjects:[self makeStringWithKeyAndValue2:@"id" value:[checkin objectForKey:@"page_id"]],
                                                            [self makeStringWithKeyAndValue2:@"location" value:[NSString stringWithFormat:@"{%@}",[locArray componentsJoinedByString:@","]]],
                                                            [self makeStringWithKeyAndValue:@"name" value:[placeName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                                                            [self makeStringWithKeyAndValue:@"city" value:[[placeDict objectForKey:@"location"] objectForKey:@"city"]],
                            [self makeStringWithKeyAndValue:@"country" value:[[placeDict objectForKey:@"location"] objectForKey:@"country"]],
                            [self makeStringWithKeyAndValue:@"state" value:[[placeDict objectForKey:@"location"] objectForKey:@"state"]],
                            [self makeStringWithKeyAndValue:@"street" value:[[[[placeDict objectForKey:@"location"] objectForKey:@"street"]
                                    stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&" withString:@" "]],
                            [self makeStringWithKeyAndValue:@"zip" value:[[placeDict objectForKey:@"location"] objectForKey:@"zip"]],
                            [self makeStringWithKeyAndValue:@"phone" value:[placeDict objectForKey:@"phone"]],
                            [self makeStringWithKeyAndValue:@"type" value:categoriesString],
                    [self makeStringWithKeyAndValue:@"pic" value:[[placeDict objectForKey:@"pic"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]],
                            [self makeStringWithKeyAndValue:@"price_range" value:[placeDict objectForKey:@"price_range"]],
                            [self makeStringWithKeyAndValue:@"website" value:[[[placeDict objectForKey:@"website"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                    stringByReplacingOccurrencesOfString:@"&" withString:@""]],
                            hoursString,
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

    NSString *data = [NSString stringWithFormat:@"fb_usercheckin={\"data\":[%@]}",[temp componentsJoinedByString:@","]];



    NSLog(@"result for user send:  %@",  data);
    _stringUserCheckins = [data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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


-(void)getFacebookUserCheckins:(RCCompleteBlockWithResult)completionBlock
{

    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    NSString *query = [NSString stringWithFormat:
            @"{"
                    @"'query1':'SELECT coords, author_uid, page_id, checkin_id FROM checkin WHERE author_uid = me()',"
                    @"'query2':'select page_id, name, type, food_styles, hours, location, categories, "
                    "phone, pic, price_range, website "
                    "from page where type in (\"RESTAURANT/CAFE\", "
                    "\"BAR\", "
                    "\"HOTEL\", \"LOCAL BUSINESS\") and page_id in (SELECT page_id, "
                    "name, type "
                    " FROM place WHERE page_id IN (SELECT page_id FROM #query1))',"
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
            //NSLog(@"user checkins result: %@", [result objectForKey:@"data"]);
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

-(void)getFacebookUserCheckinsRecent:(int)millis completionBlock:(RCCompleteBlockWithResult)completionBlock
{

    RCCompleteBlockWithResult completeBlockWithResult = completionBlock;

    NSString *query = [NSString stringWithFormat:
            @"{"
                    @"'query1':'SELECT coords, author_uid, page_id, checkin_id FROM checkin WHERE author_uid = me() AND timestamp > %li',"
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