//
//  RCMapAnnotation.h
//  Reccit
//
//  Created by Lee Way on 2/20/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class RCLocation;

@interface RCMapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, retain) RCLocation *myLocation;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end