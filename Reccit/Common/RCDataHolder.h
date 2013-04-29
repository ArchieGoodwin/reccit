//
//  RCDataHolder.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDataHolder : NSObject

+ (void)setListCountry:(NSArray *)listCountry;
+ (NSArray *)getListCountry;

+ (void)setCurrentCity:(NSString *)currentCity;
+ (NSString *)getCurrentCity;

@end
