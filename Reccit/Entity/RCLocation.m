//
//  RCLocation.m
//  Reccit
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "RCLocation.h"
#import "PDFItem.h"
#import "PDFService.h"

@implementation RCLocation

@synthesize name;
@synthesize address;
@synthesize street;
@synthesize locality;
@synthesize country;
@synthesize longitude;
@synthesize latitude;
@synthesize category;
@synthesize phoneNumber;
@synthesize state;
@synthesize city;
@synthesize zipCode;
@synthesize rating;
@synthesize ID;
@synthesize recommendation = _recommendation;
@synthesize isMark;
@synthesize index;
@synthesize comment;
@synthesize reccitCount;
@synthesize priceRange;
@synthesize type;
@synthesize genre;
@synthesize happyhours;
@synthesize friendsCount;
@synthesize listFriends;
@synthesize listFriendsName;
@synthesize distance;
@synthesize factual_id;


- (void) drawContentToPDF;
{
    UIFont * fontHeader = [UIFont systemFontOfSize:12];
    
    PDFItem * pdfItem = [[PDFItem alloc] init];
    pdfItem.text = [NSString stringWithFormat:@"%d", self.index];
    pdfItem.font = fontHeader;
    pdfItem.widthPercentage = 5;
    
    PDFItem * pdfItem1 = [[PDFItem alloc] init];
    pdfItem1.text = self.name;
    pdfItem1.font = fontHeader;
    pdfItem1.widthPercentage = 15;
    
    //PDFItem * pdfItem2 = [[PDFItem alloc] init];
    //pdfItem2.text = [NSString stringWithFormat:@"%.0lf", self.rating];
    //pdfItem2.font = fontHeader;
    //pdfItem2.widthPercentage = 8;
    
    PDFItem * pdfItem3 = [[PDFItem alloc] init];
    pdfItem3.text = self.comment;
    pdfItem3.font = fontHeader;
    pdfItem3.widthPercentage = 53;
    
    PDFItem * pdfItem4 = [[PDFItem alloc] init];
    pdfItem4.text = self.recommendation ? @"Yes" : @"No";
    pdfItem4.font = fontHeader;
    pdfItem4.widthPercentage = 17;
    
    PDFItem * pdfItem5 = [[PDFItem alloc] init];
    pdfItem5.text = self.priceRange;
    pdfItem5.font = fontHeader;
    pdfItem5.widthPercentage = 10;
    
    NSArray * arrPDFItem = [NSArray arrayWithObjects:pdfItem, pdfItem1, pdfItem3, pdfItem4, pdfItem5, nil];
    [[PDFService defaultService] writeObjects:arrPDFItem drawBorder:YES];
}


@end
