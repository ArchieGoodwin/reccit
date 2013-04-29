//
//  PDFItem.h
//  TestPDF
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFItem : NSObject
@property (nonatomic,retain) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (assign) int widthPercentage; // use for caculate width by the pagesize

// use for draw
@property (assign) int drawWidth;
@property (assign) int drawHeight;

- (CGSize) getSizeOfItem;
- (void) drawItemInRect: (CGRect) rect;

@end
