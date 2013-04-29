//
//  PDFItem.m
//  TestPDF
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//
#import "PDFItem.h"

@implementation PDFItem
@synthesize text;
@synthesize font;
@synthesize backgroundColor;
@synthesize textColor;
@synthesize widthPercentage;
@synthesize drawWidth;
@synthesize drawHeight;

- (CGSize) getSizeOfItem
{
    return CGSizeMake(100, 100);
}

- (void) drawItemInRect: (CGRect) rect
{
    
}

@end
