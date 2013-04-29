//
//  PDFService.h
//  TestPDF
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDFItem.h"
#import "ISStringUtil.h"
#define COLUMN1             @"col1"
#define COLUMN2             @"col2"
#define COLUMN3             @"col3"
#define HEADER_HEIGHT       40

@interface PDFService : NSObject{
    NSArray *currentSection;
    NSMutableData *pdfData;
    CGFloat startY;
    int startX;
    int pageNumber;
}
@property (nonatomic) CGSize pageSize;
@property (nonatomic) UIEdgeInsets pageInset;

+ (PDFService*)defaultService;
- (void) startPdfContext;
- (void) startSectionWithColumn:(NSArray *) header;
- (void)writeObjects:(NSArray *)objects withColor: (UIColor *) fontColor withRectColor: (UIColor *) rectColor drawBorder: (BOOL) isToDrawBorder;
- (void) writeObjects:(NSArray *)objects drawBorder:(BOOL) isToDrawBorder;
- (void) writeToFileWithName:(NSString*)fileName;
- (void) writeHeader;
- (void) endContext;
- (void) nextPage;
- (void) writeTitleOfFile: (NSString *) title withFont: (UIFont *) font;
- (void) drawImage: (UIImage *) image;
- (void) drawPageNumber;

@end
