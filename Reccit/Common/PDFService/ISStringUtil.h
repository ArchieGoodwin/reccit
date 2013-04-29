//
//  NSStringUtil.h
//  NhacSo
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISStringUtil : NSObject

+ (NSString *)stringReplace:(NSString *)string pattern:(NSString *)pattern template:(NSString *)template;
+ (NSString *)stringNormalization:(NSString *)string;
+ (NSString *)stripDoubleSpaceFrom:(NSString *)str;
@end
