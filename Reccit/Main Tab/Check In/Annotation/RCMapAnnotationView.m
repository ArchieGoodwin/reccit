//
//  RCMapAnnotationView.m
//  Reccit
//
//  Created by Lee Way on 2/20/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCMapAnnotationView.h"
#import "RCMapAnnotation.h"
#import "RCLocation.h"

@implementation RCMapAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString*)indentify
{
    self = [super initWithAnnotation:annotation reuseIdentifier:indentify];
    if (self) {
        [self refreshImage];
    }
    return self;
}

- (void)refreshImage {
    RCMapAnnotation *itAnnotation = (RCMapAnnotation*)self.annotation;
    
    NSString *imageName = nil;
    //NSLog(@"%@", itAnnotation.myLocation.category);
    if ([itAnnotation.myLocation.type isEqualToString:@"bar"])
    {
        imageName = @"icon-map-drink.png";
    }
    if ([itAnnotation.myLocation.type isEqualToString:@"hotel"])
    {
        imageName = @"icon-map-sleep.png";
    }
    if ([itAnnotation.myLocation.type isEqualToString:@"restaurant"])
    {
        imageName = @"icon-map-eat.png";
    }
    self.image = [UIImage imageNamed:imageName];
    
    self.frame = CGRectMake(0, 0, 23, 29);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
@end
