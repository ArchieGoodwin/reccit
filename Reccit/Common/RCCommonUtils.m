//
//  RCCommonUtils.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCCommonUtils.h"
#import "RCLocation.h"
#import "PDFService.h"
#import "PDFItem.h"

@implementation RCCommonUtils

+ (double)distanceBeetween:(CLLocationCoordinate2D)locationA andLocation:(CLLocationCoordinate2D)locationB {
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:locationA.latitude longitude:locationA.longitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:locationB.latitude longitude:locationB.longitude];
    
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
    return distance;
}

+ (void)zoomToFitMapAnnotations:(MKMapView*)mapView annotations:(NSArray*)annotations{
    CLLocationCoordinate2D leftTop = CLLocationCoordinate2DMake(-90,180);
    CLLocationCoordinate2D rightBottom = CLLocationCoordinate2DMake(90, -180);
    
    for (int i=0; i < [annotations count]; i++) {
        id<MKAnnotation> annotation = (id<MKAnnotation>)[annotations objectAtIndex:i];
        CLLocationCoordinate2D coord = annotation.coordinate;
        if (coord.latitude > leftTop.latitude) {
            leftTop.latitude = coord.latitude;
        }
        if (coord.longitude < leftTop.longitude) {
            leftTop.longitude = coord.longitude;
        }
        if (coord.latitude < rightBottom.latitude) {
            rightBottom.latitude = coord.latitude;
        }
        if (coord.longitude > rightBottom.longitude) {
            rightBottom.longitude = coord.longitude;
        }
    }
    
    MKCoordinateSpan regSpan = MKCoordinateSpanMake(leftTop.latitude-rightBottom.latitude, rightBottom.longitude-leftTop.longitude);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(leftTop.latitude-regSpan.latitudeDelta/2, leftTop.longitude+regSpan.longitudeDelta/2);
    regSpan.latitudeDelta = MAX(regSpan.latitudeDelta, 0.001);
    regSpan.longitudeDelta = MAX(regSpan.longitudeDelta, 0.001);
    MKCoordinateRegion reg = MKCoordinateRegionMake(center, regSpan);
    if (CLLocationCoordinate2DIsValid(center)) {
        [mapView setRegion:reg animated:YES];
    }
}

+ (void)showMessageWithTitle:(NSString*)title andContent:(NSString *)content
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
}


+ (BOOL)isLocationServiceOn {
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        return TRUE;
    }
    
    return FALSE;
}

+ (RCLocation *)getLocationFromDictionary:(NSDictionary *)locationDic
{
    RCLocation *location = [[RCLocation alloc] init];
    
    if ([locationDic objectForKey:@"name"] != nil && [locationDic objectForKey:@"name"] != [NSNull null]) {
        location.name = [locationDic objectForKey:@"name"];

        
        if ([locationDic objectForKey:@"place_id"] != nil && [locationDic objectForKey:@"place_id"] != [NSNull null]) {
            location.ID = [[locationDic objectForKey:@"place_id"] integerValue];
            
        }
        else
        {
            location.ID = 0;
        }
        location.genre = [locationDic objectForKey:@"genre"];
        if ([locationDic objectForKey:@"rating"] != nil && [locationDic objectForKey:@"rating"] != [NSNull null]) {
            location.rating = [[locationDic objectForKey:@"rating"] doubleValue];
        } else {
            location.rating = 0;
        }
        if ([locationDic objectForKey:@"count"] != nil && [locationDic objectForKey:@"count"] != [NSNull null]) {
            location.reccitCount = [[locationDic objectForKey:@"count"] integerValue];
        } else {
            location.reccitCount = 0;
        }
        if ([locationDic objectForKey:@"price"] != nil && [locationDic objectForKey:@"price"] != [NSNull null]) {
            location.price = [[locationDic objectForKey:@"price"] intValue];
        } else {
            location.price = 0;
        }
        location.zipCode = [locationDic objectForKey:@"zipcode"];
        if ([locationDic objectForKey:@"longitude"] != nil && [locationDic objectForKey:@"longitude"] != [NSNull null]) {
            location.longitude = [[locationDic objectForKey:@"longitude"] doubleValue];
            location.latitude = [[locationDic objectForKey:@"latitude"] doubleValue];
        }
        
        if ([locationDic objectForKey:@"address"] != nil && [locationDic objectForKey:@"address"] != [NSNull null]) {
            location.address = [locationDic objectForKey:@"address"];
            
        }
        else
        {
            location.address = @"";
        }
        if ([locationDic objectForKey:@"street"] != nil && [locationDic objectForKey:@"street"] != [NSNull null]) {
            location.street = [locationDic objectForKey:@"street"];
            
        }
        else
        {
            location.street = @"";
        }
        location.category =  [locationDic objectForKey:@"type"];
        location.state = [locationDic objectForKey:@"state"];
        location.city = [locationDic objectForKey:@"city"];
        
        if ([locationDic objectForKey:@"phone"] != nil && [locationDic objectForKey:@"phone"] != [NSNull null]) {
            location.phoneNumber = [locationDic objectForKey:@"phone"];
            
        }
        location.comment = [((NSArray *)[locationDic objectForKey:@"comments"]) componentsJoinedByString:@","];
        location.priceRange = [locationDic objectForKey:@"price_range"];
        //location.recommendation = [[locationDic objectForKey:@"recommended"] intValue] == 1;
        
        if ([locationDic objectForKey:@"reccit"] != nil && [locationDic objectForKey:@"reccit"] != [NSNull null]) {
            //NSLog(@"reccit : %i",[[locationDic objectForKey:@"reccit"] integerValue]);
            if( [[locationDic objectForKey:@"reccit"] integerValue] == 1)
            {
                location.recommendation = YES;
            }
            else
            {
                location.recommendation = NO;

            }
        }
        
        if ([locationDic objectForKey:@"happyhours"] != [NSNull null])
        {
            NSMutableArray *hours = [NSMutableArray new];
            NSMutableString *mon = [NSMutableString new];
            NSMutableString *tue = [NSMutableString new];
            NSMutableString *wed = [NSMutableString new];
            NSMutableString *thu = [NSMutableString new];
            NSMutableString *fri = [NSMutableString new];
            NSMutableString *sat = [NSMutableString new];
            NSMutableString *sun = [NSMutableString new];
            if([[locationDic objectForKey:@"happyhours"] respondsToSelector:@selector(count)])
            {
                for(NSString *hour in [locationDic objectForKey:@"happyhours"])
                {
                    
                    if([hour hasPrefix:@"Mon"])
                    {
                        [mon appendString:hour];
                        [mon appendString:@" "];
                        
                    }
                    if([hour hasPrefix:@"Tue"])
                    {
                        [tue appendString:hour];
                        [tue appendString:@" "];
                        
                    }
                    if([hour hasPrefix:@"Wed"])
                    {
                        [wed appendString:hour];
                        [wed appendString:@" "];
                        
                    }
                    if([hour hasPrefix:@"Thu"])
                    {
                        [thu appendString:hour];
                        [thu appendString:@" "];
                        
                    }
                    if([hour hasPrefix:@"Fri"])
                    {
                        [fri appendString:hour];
                        [fri appendString:@" "];
                        
                    }
                    if([hour hasPrefix:@"Sat"])
                    {
                        [sat appendString:hour];
                        [sat appendString:@" "];
                        
                    }
                    if([hour hasPrefix:@"Sun"])
                    {
                        [sun appendString:hour];
                        [sun appendString:@" "];
                        
                    }
                    
                    
                }
                [hours addObject:sun];
                [hours addObject:mon];
                [hours addObject:tue];
                [hours addObject:wed];
                [hours addObject:thu];
                [hours addObject:fri];
                [hours addObject:sat];
            }
            
            
            
            
            location.happyhours = hours;
        }
        
        if ([locationDic objectForKey:@"friends"] != [NSNull null])
        {
            NSMutableArray *listFriend = [[NSMutableArray alloc] init];
            NSMutableArray *listFriendName = [[NSMutableArray alloc] init];
            
            for (NSDictionary *friend in [locationDic objectForKey:@"friends"])
            {
                if([friend objectForKey:@"firstName"])
                {
                    NSLog(@"Friend Image: %@", [friend objectForKey:@"image"]);
                    [listFriend addObject:[friend objectForKey:@"image"]];
                    [listFriendName addObject:[NSString stringWithFormat:@"%@ %@",[friend objectForKey:@"firstName"], [friend objectForKey:@"lastName"]]];
                    
                }

            }
            
            location.listFriends = listFriend;
            location.listFriendsName = listFriendName;
            location.friendsCount = location.listFriends.count;
        }
        
        return location;

        
    }
    else
    {
        return nil;
    }

    
    
}

+ (void)drawListLocationToPDF:(NSArray *)listLocation
{
    // draw infor
    [[PDFService defaultService] setPageSize:CGSizeMake(768, 1024)];
    [[PDFService defaultService] startPdfContext];
    [[PDFService defaultService] setPageInset:UIEdgeInsetsMake(40, 40, 40, 40)];
    
    // section info
//    [[PDFService defaultService] startSectionWithColumn: nil];
//    UIFont * fontTitle = [UIFont boldSystemFontOfSize:28];
//    [[PDFService defaultService] writeTitleOfFile:self.title withFont:fontTitle];
//    [self.info_section drawContentInfo];
    
//    [[PDFService defaultService] nextPage];
    
    // content
    UIFont * fontHeader = [UIFont boldSystemFontOfSize:12];
    
    PDFItem * pdfItem = [[PDFItem alloc] init];
    pdfItem.text = @"";
    pdfItem.font = fontHeader;
    pdfItem.widthPercentage = 5;
    
    PDFItem * pdfItem1 = [[PDFItem alloc] init];
    pdfItem1.text = @"Place name";
    pdfItem1.font = fontHeader;
    pdfItem1.widthPercentage = 15;
    
    PDFItem * pdfItem2 = [[PDFItem alloc] init];
    pdfItem2.text = @"Ratings";
    pdfItem2.font = fontHeader;
    pdfItem2.widthPercentage = 10;
    
    PDFItem * pdfItem3 = [[PDFItem alloc] init];
    pdfItem3.text = @"Reviews";
    pdfItem3.font = fontHeader;
    pdfItem3.widthPercentage = 45;
    
    PDFItem * pdfItem4 = [[PDFItem alloc] init];
    pdfItem4.text = @"Recommend it?";
    pdfItem4.font = fontHeader;
    pdfItem4.widthPercentage = 10;
    
    PDFItem * pdfItem5 = [[PDFItem alloc] init];
    pdfItem5.text = @"Price Range";
    pdfItem5.font = fontHeader;
    pdfItem5.widthPercentage = 15;
    
    NSArray * arrHeader = [NSArray arrayWithObjects:pdfItem, pdfItem1, pdfItem2, pdfItem3, pdfItem4, pdfItem5, nil];
    
    [[PDFService defaultService] startSectionWithColumn: arrHeader];
    [[PDFService defaultService] drawPageNumber];
    [[PDFService defaultService] writeHeader];
    
    for (RCLocation *location in listLocation)
    {
        location.index = [listLocation indexOfObject:location] + 1;
        [location drawContentToPDF];
    }
    
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:@"share.pdf"];
    NSLog(@"WRITE TO: %@", documentDirectoryFilename);
    
    [[PDFService defaultService] endContext];
    [[PDFService defaultService] writeToFileWithName:documentDirectoryFilename];
}

BOOL IS_IPHONE5_RETINA(void) {
    BOOL isiPhone5Retina = NO;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([UIScreen mainScreen].scale == 2.0f) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960){
                //NSLog(@"iPhone 4, 4s Retina Resolution");
            }
            if(result.height == 1136){
                //NSLog(@"iPhone 5 Resolution");
                isiPhone5Retina = YES;
            }
        } else {
            //NSLog(@"iPhone Standard Resolution");
        }
    }
    return isiPhone5Retina;
}


+(BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                //NSLog(@"iPhone 4 Resolution");
                return NO;
            }
            if(result.height == 1136) {
                //NSLog(@"iPhone 5 Resolution");
                //[[UIScreen mainScreen] bounds].size =result;
                return YES;
            }
        }
        else{
            // NSLog(@"Standard Resolution");
            return NO;
        }
    }
    return NO;
}

@end
