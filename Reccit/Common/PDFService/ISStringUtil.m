//
//  NSStringUtil.m
//  NhacSo
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "ISStringUtil.h"

@implementation ISStringUtil

+ (NSString *)stringReplace:(NSString *)string pattern:(NSString *)pattern template:(NSString *)template
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
	return [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:template];
}

+ (NSString *)stringNormalization:(NSString *)string
{
    if (string == nil) {
        return nil;
    }
    NSString *str = [NSString stringWithFormat:@"%@", string];
    
    str = [self stringReplace:str pattern:@"(à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ)" template:@"a"];
    str = [self stringReplace:str pattern:@"(è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ)" template:@"e"];
    str = [self stringReplace:str pattern:@"(ì|í|ị|ỉ|ĩ)" template:@"i"];
    str = [self stringReplace:str pattern:@"(ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ)" template:@"o"];
    str = [self stringReplace:str pattern:@"(ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ)" template:@"u"];
    str = [self stringReplace:str pattern:@"(ỳ|ý|ỵ|ỷ|ỹ)" template:@"y"];
    str = [self stringReplace:str pattern:@"(đ)" template:@"d"];
    
    str = [self stringReplace:str pattern:@"(À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ)" template:@"A"];
    str = [self stringReplace:str pattern:@"(È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ)" template:@"E"];
    str = [self stringReplace:str pattern:@"(Ì|Í|Ị|Ỉ|Ĩ)" template:@"I"];
    str = [self stringReplace:str pattern:@"(Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ)" template:@"O"];
    str = [self stringReplace:str pattern:@"(Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ)" template:@"U"];
    str = [self stringReplace:str pattern:@"(Ỳ|Ý|Ỵ|Ỷ|Ỹ)" template:@"Y"];
    str = [self stringReplace:str pattern:@"(Đ)" template:@"D"];
    return [self stripDoubleSpaceFrom:str];
}

+ (NSString *)stripDoubleSpaceFrom:(NSString *)str {
    if (str == nil) {
        return @"";
    }
    while ([str rangeOfString:@"  "].location != NSNotFound) {
        str = [str stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    return str;
}

@end
