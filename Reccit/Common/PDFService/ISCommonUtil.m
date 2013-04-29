//
//  NSCommonUtil.m
//  NhacSo
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import "ISCommonUtil.h"
#import "Reachability.h"
@implementation ISCommonUtil
+ (void)toggleNetworkIndicatorVisible:(BOOL)visible{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:visible];
}
+ (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval withFormat:(NSString *)format{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)stringFromSongDuration:(int)duration
{
    duration = duration / 1000;
    return [NSString stringWithFormat:@"%02d:%02d", (int)(duration/60), (int)duration%60];
}

+ (NSString *)stringFromSongDurationInSecond:(int)duration
{
    return [NSString stringWithFormat:@"%02d:%02d", (int)(duration/60), (int)duration%60];
}

+ (NSString *)stringFromSongSize:(int)filesize
{
    return [NSString stringWithFormat:@"%.1f MB", (float) filesize / (1024*1024)];
}

+ (BOOL)isNetworkConnected{
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    CGFloat scaleRatio = 0;
    if ((newSize.width / newSize.height) > (image.size.width / image.size.height)) {
        scaleRatio = (newSize.height / image.size.height);
    } else {
        scaleRatio = (newSize.width / image.size.width);
    }
    
    CGSize newSizeToFit = CGSizeMake(scaleRatio * image.size.width, scaleRatio * image.size.height);
    
    UIGraphicsBeginImageContextWithOptions(newSizeToFit, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSizeToFit.width, newSizeToFit.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *) getCurrentDate: (NSString *) format
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString;
}
@end
