//
// Created by sdikarev on 4/11/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "RCDefine.h"

@interface facebookHelper : NSObject




@property (nonatomic, strong) NSMutableArray *checkins;
@property (nonatomic, strong) NSMutableArray *userCheckins;
@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) NSMutableArray *userPlaces;
@property (nonatomic, strong) NSMutableDictionary *resultUserCheckins;
@property (nonatomic, strong) NSMutableDictionary *resultFriendsCheckins;
@property (nonatomic, strong)  NSArray* friends;
@property (nonatomic, strong)  NSMutableArray* friendsCheckinsArray;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *stringUserCheckins;
@property (nonatomic, strong) NSString *stringFriendsCheckins;
@property (nonatomic, assign) NSInteger friendsCount;
@property (nonatomic, strong) NSMutableArray *userCheckinsArray;


+(id)sharedInstance;
-(void)getFacebookQuery:(RCCompleteBlockWithResult)completionBlock;
-(void)getFacebookMe;
-(void)getFacebookRecentCheckins;
-(void)getFacebookQueryRecent:(NSDate *)lastDate  completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(void)getFacebookUserCheckins:(RCCompleteBlockWithResult)completionBlock;
-(void)getFacebookQueryWithTimePaging:(RCCompleteBlockWithResult)completionBlock;
-(void)facebookQueryWithTimePaging:(long)offset completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(void)facebookQueryWithTimePagingRecent:(long)offset completionBlock:(RCCompleteBlockWithResult)completionBlock;
-(void)getFacebookUserCheckinsRecent2:(long)offset  completionBlock:(RCCompleteBlockWithResult)completionBlock;
@end