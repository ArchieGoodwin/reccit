//
//  ISPDFItemImage.m
//  iSurvey
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "ISPDFItemImage.h"
#import "ISCommonUtil.h"

@implementation ISPDFItemImage
@synthesize image;


// override PDFItem
- (CGSize) getSizeOfItem
{
    if (self.image == nil) {
        return CGSizeMake(0, 0);
    } else {
        
        UIImage * resizedImage = [ISCommonUtil imageWithImage:self.image scaledToSize:CGSizeMake(200, 200)];
        return resizedImage.size;
    }
}

- (void) drawItemInRect: (CGRect) rect
{
    if (self.image == nil) {
        return;
    }
    UIImage * resizedImage = [ISCommonUtil imageWithImage:self.image scaledToSize:rect.size];
    
    [resizedImage drawInRect:CGRectMake(rect.origin.x, rect.origin.y, resizedImage.size.width, resizedImage.size.height)];
}

@end
