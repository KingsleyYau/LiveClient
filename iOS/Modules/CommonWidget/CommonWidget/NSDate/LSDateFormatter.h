//
//  LSDateFormatter.h
//  CommonWidget
//
//  Created by Max on 2017/10/16.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDateFormatter : NSObject
// NSDate to NSString. ie hh:mm
+ (NSString *)toStringHM:(NSDate *)date;
// NSDate to NSString. ie mm-dd
+ (NSString *)toStringMD:(NSDate *)date;
// NSDate to NSString. ie mm-dd
+ (NSString *)toStringMDCH:(NSDate *)date;
// NSDate to NSString. ie m-d hh:mm
+ (NSString *)toStringMDHM:(NSDate *)date;
// NSDate to NSString. ie yyyy-mm-dd
+ (NSString *)toStringYMD:(NSDate *)date;
// NSDate to NSString. ie yyyy-mm-dd hh:mm:ss
+ (NSString *)toStringYMDHMS:(NSDate *)date;
// NSDate to NSString. ie yyyy-mm-dd hh:mm
+ (NSString *)toStringYMDHM:(NSDate *)date;
// NSDate to NSString. ie yy-mm-dd hh:mm
+ (NSString *)toString2YMDHM:(NSDate *)date;
// NsDate to NSString. ie if(today){ hh:mm } else { yy-mm-dd }
+ (NSString *)toStringToday:(NSDate *)date;
/** CrashFileDate */
+ (NSString *)toStringCrashDate:(NSDate *)date;
/** CrashZipDate */
+ (NSString *)toStringCrashZipDate:(NSDate *)date;

// return the time set for start hour. ie yyyy-mm-dd 00:00:00
+ (NSDate *)getDayStartTime:(NSDate *)date;
// return the time set for end hour, minute, secend. ie yyyy-mm-dd 23:59:59
+ (NSDate *)getDayEndTime:(NSDate *)date;

+ (NSString *)dateStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle date:(NSDate *)date;

// offset day. ie self=2012-01-05 day=1 return 2012-01-06, self=2012-01-05 day=-1 return 2012-01-04.
+ (NSDate *)offsetDay:(NSInteger)day date:(NSDate *)date;

+ (NSDate *)dateAfterMonth:(NSInteger)month date:(NSDate *)date;

@end
