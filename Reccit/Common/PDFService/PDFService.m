//
//  PDFService.m
//  TestPDF
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "PDFService.h"
#import "ISCommonUtil.h"
#import "ISPDFItemImage.h"
#import "ISPDFItemText.h"

static PDFService * instance = nil;
@implementation PDFService
@synthesize pageSize;
@synthesize pageInset;
+ (PDFService *)defaultService{
    if (!instance) {
        instance = [[PDFService alloc] init];
    }
    return instance;
}

- (void)startPdfContext{
    pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    UIGraphicsBeginPDFPage();
    startY = 40;
    pageNumber = 1;
}

- (void)startSectionWithColumn: (NSArray *) arr{
    if (arr) {
        currentSection = arr;
    } else {
        currentSection = nil;
    }
}

- (void) writeHeader
{
    if (currentSection == nil) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetRGBStrokeColor(ctx, 0.1, 0.1, 0.1, 1.0);
//    CGContextSetRGBFillColor(ctx, 0.8, 0.8, 0.8, 0.9);
    
    int objectCount = [currentSection count];
    startX = pageInset.left;
    
    int maxHeight = 0;
    
    // calculate height to draw
    for (int objectIdx = 0; objectIdx < objectCount; objectIdx++) {
        PDFItem * writeItem = [currentSection objectAtIndex:objectIdx];
        int widthItem = (pageSize.width - pageInset.left - pageInset.right) * writeItem.widthPercentage / 100;
        writeItem.drawWidth = widthItem;
        
        // get height of a row to draw
        NSString *str =  [ISStringUtil stripDoubleSpaceFrom:[writeItem text]];
        CGSize size = {widthItem,2000.0f};
        CGSize newSize = [str sizeWithFont:writeItem.font
                         constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        if (newSize.height + 10 > maxHeight) {
            maxHeight = newSize.height + 10;
        }
    }
    
    // draw text
    startX = pageInset.left;
    for (int objectIdx = 0; objectIdx < objectCount; objectIdx++) {
        PDFItem * writeItem = [currentSection objectAtIndex:objectIdx];
        writeItem.drawHeight = maxHeight;
        
        // IMPORTANCE: draw rect befor draw text
        CGRect drawRectFrame  = CGRectMake(startX, startY, writeItem.drawWidth, writeItem.drawHeight);
        [self drawRect:drawRectFrame lineWidth:1.0];
        
        CGRect drawFrame  = CGRectMake(startX + 5, startY + 5, writeItem.drawWidth - 10, writeItem.drawHeight - 10);
        NSString *str = [ISStringUtil stripDoubleSpaceFrom:[writeItem text]];
        
        [str drawInRect:drawFrame
               withFont:writeItem.font
          lineBreakMode:NSLineBreakByWordWrapping
         alignment:NSTextAlignmentCenter];
        
        startX += writeItem.drawWidth;
    }
    
    // update current Y dimension to draw
    startY += maxHeight;
    startY -= 0.5;
}

- (void) writeObjects:(NSArray *)objects drawBorder:(BOOL) isToDrawBorder;
{
    [self writeObjects:objects withColor:[UIColor blackColor] withRectColor:[UIColor whiteColor] drawBorder:isToDrawBorder];
}

- (void) drawImage: (UIImage *) image;
{
    UIImage * resizedImage = [ISCommonUtil imageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    
    startX = 0;
    startX = pageInset.left;
    if ((resizedImage.size.height + startY + 10) > (pageSize.height - pageInset.top - pageInset.bottom)) {
        UIGraphicsBeginPDFPage();
        pageNumber++;
        [self drawPageNumber];
        startY = pageInset.top;
    }
    CGRect rect = CGRectMake(startX, startY, pageSize.width - pageInset.left - pageInset.right, resizedImage.size.height + 10);
    
    [self drawRect:rect lineWidth:1.0];
    
    [resizedImage drawInRect:CGRectMake(startX + 5, startY + 5, resizedImage.size.width, resizedImage.size.height)];
    startY += resizedImage.size.height + 10;
}

- (void)writeObjects:(NSArray *)objects withColor: (UIColor *) fontColor withRectColor: (UIColor *) rectColor drawBorder: (BOOL) isToDrawBorder
{
    // prepare to draw
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGContextSetRGBStrokeColor(ctx, 0.1, 0.1, 0.1, 1.0);
    
    int objectCount = [objects count];
    startX = pageInset.left;
    
    int maxHeight = 0;
    
    // calculate height to draw
    for (int objectIdx = 0; objectIdx < objectCount; objectIdx++) {
        PDFItem * writeItem = [objects objectAtIndex:objectIdx];
        int widthItem = (pageSize.width - pageInset.left - pageInset.right) * writeItem.widthPercentage / 100;
        writeItem.drawWidth = widthItem;
        if (startY < 0) {
            startY = pageInset.top;
        }
        CGSize newSize;
        // get height of a row to draw
        if ([writeItem isKindOfClass:[ISPDFItemImage class]]) {
            newSize = [((ISPDFItemImage *) writeItem) getSizeOfItem];
        }
        else {
            NSString *str =  [ISStringUtil stripDoubleSpaceFrom:[writeItem text]];
            CGSize size = {widthItem,2000.0f};
            newSize = [str sizeWithFont:writeItem.font
                             constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        }
        if (newSize.height + 15 > maxHeight) {
            maxHeight = newSize.height + 15;
        }
    }
    // if height to draw is larger than height of document, draw header
    if ((maxHeight + startY) > (pageSize.height - pageInset.top - pageInset.bottom)) {
        // write header
        UIGraphicsBeginPDFPage();
        pageNumber++;
        [self drawPageNumber];
        startY = pageInset.top;
        [self writeHeader];
    }
    
    // draw text
    startX = pageInset.left;
    for (int objectIdx = 0; objectIdx < objectCount; objectIdx++) {
        PDFItem * writeItem = [objects objectAtIndex:objectIdx];
        writeItem.drawHeight = maxHeight;
        
        CGRect drawRectFrame  = CGRectMake(startX, startY, writeItem.drawWidth, writeItem.drawHeight);
        if (isToDrawBorder) {
            [self drawRect:drawRectFrame lineWidth:1.0];
        }
        
        CGRect drawFrame  = CGRectMake(startX + 5, startY + 5, writeItem.drawWidth - 10, writeItem.drawHeight - 10);
        if ([writeItem isKindOfClass:[ISPDFItemImage class]]) {
            [((ISPDFItemImage *) writeItem) drawItemInRect:drawFrame];
        }
        else {
            NSString *str = [ISStringUtil stripDoubleSpaceFrom:[writeItem text]];
            [str drawInRect:drawFrame
                   withFont:writeItem.font
              lineBreakMode:NSLineBreakByWordWrapping
             ];
        }
        startX += writeItem.drawWidth;
    }
    
    // update current Y dimension to draw
    startY += maxHeight;
    startY -= 0.5;
}

- (void) nextPage
{
    UIGraphicsBeginPDFPage();
    pageNumber++;
    [self drawPageNumber];
    startY = pageInset.top;
}

- (void) drawPageNumber
{
    NSString * strPage = [NSString stringWithFormat:@"%d", pageNumber];
    CGRect rectPage = CGRectMake(0,
                                   self.pageSize.height - self.pageInset.bottom,
                                   self.pageSize.width,
                                   self.pageInset.bottom);
    [strPage drawInRect:rectPage withFont:[UIFont systemFontOfSize:8] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

- (void)drawRect:(CGRect)rect lineWidth: (float) lineWidth;
{
    [self drawRect:rect lineWidth:lineWidth fontColor:[UIColor blackColor] rectColor:[UIColor whiteColor]];
}

- (void)drawRect:(CGRect)rect lineWidth: (float) lineWidth fontColor: (UIColor *) color rectColor: (UIColor *) rectColor;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextAddRect(context, rect);
    CGContextClosePath(context);
    
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokePath(context); // do actual stroking
}

- (void) fillRect: (CGRect) rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, rect);
}


- (void)writeToFileWithName:(NSString *)fileName{
    [pdfData writeToFile:fileName
              atomically:YES];
}

- (void) writeTitleOfFile: (NSString *) title withFont: (UIFont *) font {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(100, 100, self.pageSize.width - 200, font.lineHeight)];
    [textView setText:title];
    [textView sizeToFit];
    
    // draw
    [title drawInRect:textView.frame withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    startY = textView.frame.origin.y + textView.frame.size.height + 100;
    
    // draw pagenumber
    [self drawPageNumber];
}


- (void)endContext{
    UIGraphicsEndPDFContext();
}


@end
