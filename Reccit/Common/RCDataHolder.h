//
//  RCDataHolder.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface RCDataHolder : NSObject

+(void)setPlacemark:(CLPlacemark *)p;
+ (CLPlacemark *)getPlacemark;


+ (void)setListCountry:(NSArray *)listCountry;
+ (NSArray *)getListCountry;

+ (void)setCurrentCity:(NSString *)currentCity;
+ (NSString *)getCurrentCity;

@end
