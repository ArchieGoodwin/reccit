//
//  RCCommonUtils.h
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class RCLocation;
@interface RCCommonUtils : NSObject

+ (double)distanceBeetween:(CLLocationCoordinate2D)locationA andLocation:(CLLocationCoordinate2D)locationB;
+ (void)zoomToFitMapAnnotations:(MKMapView*)mapView annotations:(NSArray*)annotations;

+ (void)showMessageWithTitle:(NSString*)title andContent:(NSString *)content;

+ (BOOL)isLocationServiceOn;

+ (RCLocation *)getLocationFromDictionary:(NSDictionary *)locationDic;

+ (void)drawListLocationToPDF:(NSArray *)listLocation;
-(BOOL)isIphone5;
BOOL IS_IPHONE5_RETINA(void);

@end
