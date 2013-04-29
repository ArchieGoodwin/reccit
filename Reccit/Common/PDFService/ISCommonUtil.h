//
//  NSCommonUtil.h
//  NhacSo
//
//  Created by Lee Way on 1/26/13.
//  Copyright (c) 2013 leeway. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MC_LOCALIZE(__st)               NSLocalizedString(__st,@"")
#define MC_RELEASE(__p)                 if (__p){[__p release];__p = nil;}
#define APP_DELEGATE                (NSAppDelegate *)[[UIApplication sharedApplication] delegate]
@interface ISCommonUtil : NSObject
+ (void) toggleNetworkIndicatorVisible:(BOOL)visible;
+ (NSString*) stringFromTimeInterval:(NSTimeInterval)timeInterval withFormat:(NSString*)format;
+ (NSString*) stringFromSongDuration:(int)duration;
+ (NSString *)stringFromSongDurationInSecond:(int)duration;
+ (NSString*) stringFromSongSize:(int)filesize;
+ (BOOL) isNetworkConnected;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSString *) getCurrentDate: (NSString *) format;
@end
