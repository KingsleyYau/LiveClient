//
//  LSDateFormatter.m
//  CommonWidget
//
//  Created by Max on 2017/10/16.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSDateFormatter.h"

@implementation LSDateFormatter
+ (NSString *)toStringMDHM:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];

    return [NSString stringWithFormat:@"%ld-%ld %.2ld:%.2ld", (long)month, (long)day, (long)hour, (long)minute];
}

+ (NSString *)toStringHM:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];

    return [NSString stringWithFormat:@"%.2ld:%.2ld", (long)hour, (long)minute];
}

+ (NSString *)toStringYMD:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *string = [formatter stringFromDate:date];
    [formatter release];
    return string;
}

+ (NSString *)toStringMD:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];

    return [NSString stringWithFormat:@"%ld-%ld", (long)month, (long)day];
}
+ (NSString *)toStringMDCH:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];

    return [NSString stringWithFormat:@"%ld月%ld日", (long)month, (long)day];
}

+ (NSString *)toStringYMDHMS:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    NSInteger second = [comoponents second];

    return [NSString stringWithFormat:@"%ld-%ld-%ld %ld:%.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute, (long)second];
}

+ (NSString *)toStringYMDHMSWithUnderLine:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    NSInteger second = [comoponents second];

    return [NSString stringWithFormat:@"%ld_%ld_%ld_%ld_%.2ld_%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute, (long)second];
}

+ (NSString *)toStringYMDHM:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];

    return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute];
}

+ (NSString *)toString2YMDHM:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];

    return [NSString stringWithFormat:@"%.2ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year % 100, (long)month, (long)day, (long)hour, (long)minute];
}
+ (NSString *)toStringToday:(NSDate *)date {
    NSDate *dayBegin = [LSDateFormatter getDayStartTime:date];
    NSDate *dayEnd = [LSDateFormatter getDayEndTime:date];
    if ([[date earlierDate:dayEnd] isEqualToDate:[date laterDate:dayBegin]]) {
        // today
        return [LSDateFormatter toStringHM:date];
    } else
        return [LSDateFormatter toStringYMD:date];
}

+ (NSString *)toStringCrashDate:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month] + 1;
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];

    return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute];
}

+ (NSString *)toStringCrashZipDate:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year] + 1900;
    NSInteger month = [comoponents month] + 1;
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    NSInteger sec = [comoponents second];
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld_[%02ld-%02ld-%02ld]", (long)year, (long)month,
                                      (long)day, (long)hour, (long)minute, (long)sec];
}

+ (NSString *)dateStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle date:(NSDate *)date {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];

    NSString *dateString = nil;
    NSString *timeString = nil;
    // date
    if (NSDateFormatterNoStyle != dateStyle) {
        [formatter setDateStyle:dateStyle];
        dateString = [formatter stringFromDate:date];
        [formatter setDateStyle:NSDateFormatterNoStyle];
    }

    // time
    if (NSDateFormatterNoStyle != dateStyle) {
        [formatter setTimeStyle:timeStyle];
        timeString = [formatter stringFromDate:date];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    }

    if (NSDateFormatterNoStyle != dateStyle && NSDateFormatterNoStyle != dateStyle) {
        return [NSString stringWithFormat:@"%@ %@", dateString, timeString];
    } else {
        return (NSDateFormatterNoStyle != dateStyle ? dateString : timeString);
    }
}

/** 崩溃日志日期 */
+ (NSString *)toCrashLogStringYMDHM:(NSDate *)date {
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:date];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month] + 1;
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];

    return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute];
}

// return the time set for start hour. ie yyyy-mm-dd 00:00:00
+ (NSDate *)getDayStartTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *strDate = [NSString stringWithFormat:@"%@ 00:00:00", [LSDateFormatter toStringYMD:date]];
    NSDate *startDate = [formatter dateFromString:strDate];

    [formatter release];

    return startDate;
}

// return the time set for end hour, minute, secend. ie yyyy-mm-dd 23:59:59
+ (NSDate *)getDayEndTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString *strDate = [NSString stringWithFormat:@"%@ 23:59:59", [LSDateFormatter toStringYMD:date]];
    NSDate *endDate = [formatter dateFromString:strDate];

    [formatter release];

    return endDate;
}

// offset day. ie LSDateFormatter=2012-01-05 day=1 return 2012-01-06, LSDateFormatter=2012-01-05 day=-1 return 2012-01-04.
+ (NSDate *)offsetDay:(NSInteger)day date:(NSDate *)date {
    NSTimeInterval interval = (86400.0 * day);
    return [date dateByAddingTimeInterval:interval];
}

+ (NSDate *)dateAfterMonth:(NSInteger)month date:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setMonth:month];
    NSDate *newDate = [calendar dateByAddingComponents:componentsToAdd toDate:date options:0];
    [componentsToAdd release];
    return newDate;
}
@end
