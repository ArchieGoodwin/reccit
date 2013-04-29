//
//  MapViewController.m
//  Miller
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"

@interface MapView()

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;

@end

@implementation MapView

@synthesize lineColor;

- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		mapView.showsUserLocation = YES;
		[mapView setDelegate:self];
		[self addSubview:mapView];
		routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
		routeView.userInteractionEnabled = NO;
		[mapView addSubview:routeView];
		
		self.lineColor = [UIColor colorWithWhite:0.2 alpha:1.0];
	}
	return self;
}

-(void) centerMap {
	MKCoordinateRegion region;

	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < self.routes.count; idx++)
	{
		CLLocation* currentLocation = [self.routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[mapView setRegion:region animated:YES];
}

-(void) showRouteTo:(Place*)t {
	
	if(self.routes) {
		[mapView removeAnnotations:[mapView annotations]];
	}
	
	PlaceMark* to = [[PlaceMark alloc] initWithPlace:t];
	[mapView addAnnotation:to];
    
	[self updateRouteView];
	[self centerMap];
}

-(void) updateRouteView {
	CGContextRef context = 	CGBitmapContextCreate(nil, 
												  routeView.frame.size.width, 
												  routeView.frame.size.height, 
												  8, 
												  4 * routeView.frame.size.width,
												  CGColorSpaceCreateDeviceRGB(),
												  kCGImageAlphaPremultipliedLast);
	
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 4.0);
	
	for(int i = 0; i < self.routes.count; i++) {
		CLLocation* location = [self.routes objectAtIndex:i];
		CGPoint point = [mapView convertCoordinate:location.coordinate toPointToView:routeView];
		
		if(i == 0) {
			CGContextMoveToPoint(context, point.x, routeView.frame.size.height - point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, routeView.frame.size.height - point.y);
		}
	}
	
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
	
	routeView.image = img;
	CGContextRelease(context);

}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self updateRouteView];
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}

@end
