//
//  RCDefine.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//
#import "RCConversation.h"
#ifndef Reccit_RCDefine_h
#define Reccit_RCDefine_h

#define kRCCurrentCity                  @"CurrentCity"

#define kRCFirstTimeLogin               @"kRCFirstTimeLogin"

#define kRCFacebookLoggedIn             @"FacebookLoggedIn"
#define kRCTwitterLoggedIn              @"TwitterLoggedIn"
#define kRCFoursquareLoggedIn           @"FoursquareLoggedIn"

#define kRCTwitterOAuthConsumerKey      @"vzeiH58acxBFwoaCQUje3g"
#define kRCTwitterOAuthConsumerSecret   @"O2LxGDkdYraUeimb8BjgEuG6GrpI01xBf0ybifkXE"

#define kRCFoursquareClientID           @"PFIF2DUBKYJTDVN5WRR02ULAX3DWGZ5YSGRQXFC2VSUD5UN2"
#define kRCFoursquareCallbackURL        @"fsqdemo://foursquare"

#define kRCUserImageUrl                 @"LoginUserImageUrl"
#define kRCUserName                     @"LoginUserName"
#define kRCUserFacebookId               @"kRCUserFacebookId"
#define kRCUserFacebookName             @"kRCUserFacebookName"
#define kRCUserId                       @"LoginUserId"

#define kRCTwitterUserId                @"TwitterUserId"
#define kRCFoursquareUserId             @"FoursquareUserId"


#define kSendUserChekins @"http://bizannouncements.com/bhavesh/getUser.php?auth=fbook&user=%@&type=usercheckin&token=%@&device=ios"
#define kSendUserChekinsDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/checkin/checkin.svc/CheckinPlaces?auth=facebook&fbid=%@&type=usercheckin&token=%@"
#define kSendUserChekins4sDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/checkin/checkin.svc/CheckinPlaces?auth=foursquare&fbid=%@&type=usercheckin&token=%@"

#define kSendFriendsChekins @"http://bizannouncements.com/bhavesh/getUser.php?auth=fbook&user=%@&type=friendcheckin&token=%@&device=ios"
#define kSendFriendsChekinsDOTNET @"http://reccit.elasticbeanstalk.com/Authentication_deploy/checkin/checkin.svc/CheckinFriendPlaces?auth=facebook&fbid=%@&type=friendschekin&token=%@"



// API



#define kRCAPIFacebookAuthenticate      @"http://bizannouncements.com/Vega/services/app/register.php?type=facebook&from=web&access_token=%@&facebookid=%@"
#define kRCAPIFacebookAuthenticateDOTNET      @"http://reccit.elasticbeanstalk.com/Authentication_deploy/Auth.svc/Authenticate?oauth_token=%@&type=facebook&facebookid=%@"

//#define kRCAPIFacebookAuthenticate @"http://bizannouncements.com/Vega/services/facebook/authenticate.php?access_token=%@"

#define kRCAPITwitterAuthenticate @"http://bizannouncements.com/Vega/services/twitter/authentication.php?oauth_token=%@&oauth_secret=%@"
//#define kRCAPITwitterAuthenticate      @"http://bizannouncements.com/Vega/services/app/register.php?type=twitter&from=web&access_token=%@"
#define kRCAPIFoursquareAuthenticate      @"http://bizannouncements.com/Vega/services/foursquare/authenticate.php&access_token=%@"

// Color
#define kRCBackgroundView [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0]

#define kRCCheckInCellColorHighLight [UIColor colorWithRed:239.0/255 green:239.0/255 blue:239.0/255 alpha:1.0]
#define kRCCheckInAddCellColorHighLight [UIColor colorWithRed:203.0/255 green:203.0/255 blue:203.0/255 alpha:1.0]

#define kRCPrefixTextCellColorHighLight [UIColor colorWithRed:58.0/255 green:76.0/255 blue:152.0/255 alpha:1.0]

#define kRCTextCellColorHighLight [UIColor colorWithRed:149.0/255 green:149.0/255 blue:149.0/255 alpha:1.0]
#define kRCTableViewCellColorHighLight [UIColor colorWithRed:243.0/255 green:243.0/255 blue:243.0/255 alpha:1.0]
#define kRCTextColor [UIColor colorWithRed:58.0/255 green:76.0/255 blue:153.0/255 alpha:1.0]


typedef void (^RCCompleteBlockWithResult)  (BOOL result, NSError *error);
typedef void (^RCCompleteBlockWithIntResult)  (int newmessages, NSError *error);

typedef void (^RCCompleteBlockWithMessageResult)  (RCMessage *result, NSError *error);

typedef void (^RCCompleteBlockWithConvResult)  (RCConversation *result, NSError *error);

typedef void (^RCCompleteBlockWithArrayResult)  (NSMutableArray *result, NSError *error);


#endif
