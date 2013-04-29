//
//  RCDataHolder.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCDataHolder.h"

@implementation RCDataHolder


static NSString *currentCityText;
static NSArray *listAllCountry;

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
