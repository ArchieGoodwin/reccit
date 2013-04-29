//
//  RCLocation.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCLocation : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *locality;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *zipCode;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *priceRange;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, assign) int reccitCount;
@property (nonatomic, assign) double rating;
@property (nonatomic, assign) int ID;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int price;
@property (nonatomic, assign) BOOL recommendation;
@property (nonatomic, assign) BOOL isMark;
@property (nonatomic, copy) NSMutableArray *happyhours;
@property (nonatomic, copy) NSMutableArray *listFriends;

@property (nonatomic, copy) NSMutableArray *listFriendsName;

- (void) drawContentToPDF;

@end
