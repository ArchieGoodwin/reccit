//
//  RCDataHolder.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCDataHolder.h"
#import <MapKit/MapKit.h>
@implementation RCDataHolder

static CLPlacemark *placemark;
static NSString *currentCityText;
static NSArray *listAllCountry;



+ (void)setPlacemark:(CLPlacemark *)p
{
    placemark = p;
}
+ (CLPlacemark *)getPlacemark
{
    return placemark;
}


+ (void)setListCountry:(NSArray *)listCountry
{
    listAllCountry = listCountry;
}

+ (NSArray *)getListCountry
{
    return listAllCountry;
}

+ (void)setCurrentCity:(NSString *)currentCity
{
    currentCityText = currentCity;
}

+ (NSString *)getCurrentCity
{
    return currentCityText;
}


@end
