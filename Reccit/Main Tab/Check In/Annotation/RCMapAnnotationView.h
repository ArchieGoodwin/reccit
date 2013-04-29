//
//  RCMapAnnotationView.h
//  Reccit
//
//  Created by Lee Way on 2/20/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RCMapAnnotationView : MKAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>) annotation reuseIdentifier:(NSString*)indentify;

- (void)refreshImage;

@end
