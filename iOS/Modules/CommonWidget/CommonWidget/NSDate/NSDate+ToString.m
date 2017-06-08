//
//  NSDate+ToString.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "NSDate+ToString.h"

@implementation NSDate (ToString)
-(NSString*)toStringMDHM
{
    NSUInteger componentFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    
    return [NSString stringWithFormat:@"%ld-%ld %.2ld:%.2ld", (long)month, (long)day, (long)hour, (long)minute];
}

-(NSString*)toStringHM
{
    NSUInteger componentFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    
    return [NSString stringWithFormat:@"%.2ld:%.2ld", (long)hour, (long)minute];
}

-(NSString*)toStringYMD
{
//    NSUInteger componentFlags = NSCalendarUnitYear | NSMonthCalendarUnit | NSCalendarUnitDay;
//    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
//    NSInteger year = [comoponents year];
//    NSInteger month = [comoponents month];
//    NSInteger day = [comoponents day];
//    
//    return [NSString stringWithFormat:@"%d-%d-%d", year, month, day];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *string = [formatter stringFromDate:self];
    [formatter release];
    return string;
}

-(NSString*)toStringMD
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    
    return [NSString stringWithFormat:@"%ld-%ld", (long)month, (long)day];
}
-(NSString*)toStringMDCH
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    
    return [NSString stringWithFormat:@"%ld月%ld日", (long)month, (long)day];
}
-(NSString*)toStringYMDHMS
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    NSInteger second = [comoponents second];
    
    return [NSString stringWithFormat:@"%ld-%ld-%ld %ld:%.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute, (long)second];
}

-(NSString*)toStringYMDHM
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    
    return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute];
}

-(NSString*)toString2YMDHM
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month];
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    
    return [NSString stringWithFormat:@"%.2ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year%100, (long)month, (long)day, (long)hour, (long)minute];
}
- (NSString *)toStringToday {
    NSDate *dayBegin = [[NSDate date] getDayStartTime];
    NSDate *dayEnd = [[NSDate date] getDayEndTime];
    if([[self earlierDate:dayEnd] isEqualToDate:[self laterDate:dayBegin]]) {
        // today
        return [self toStringHM];
    }
    else 
        return [self toStringYMD];
}

-(NSString*)toStringCrashDate
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month] + 1;
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    
    return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute];
    
}

- (NSString *)toStringCrashZipDate
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger year = [comoponents year] + 1900;
    NSInteger month = [comoponents month] + 1;
    NSInteger day = [comoponents day] ;
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    NSInteger sec = [comoponents second];
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld_[%02ld-%02ld-%02ld]",(long)year, (long)month, \
            (long)day, (long)hour, (long)minute, (long)sec];
    
}


- (NSString *)dateStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    
    NSString *dateString = nil;
    NSString *timeString = nil;
    // date
    if (NSDateFormatterNoStyle != dateStyle){
        [formatter setDateStyle:dateStyle];
        dateString = [formatter stringFromDate:self];
        [formatter setDateStyle:NSDateFormatterNoStyle];
    }
    
    // time
    if (NSDateFormatterNoStyle != dateStyle){
        [formatter setTimeStyle:timeStyle];
        timeString = [formatter stringFromDate:self];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    if (NSDateFormatterNoStyle != dateStyle && NSDateFormatterNoStyle != dateStyle){
        return [NSString stringWithFormat:@"%@ %@", dateString, timeString];
    }
    else{
        return (NSDateFormatterNoStyle!=dateStyle ? dateString : timeString);
    }
}

/** 崩溃日志日期 */
-(NSString*)toCrashLogStringYMDHM
{
    NSUInteger componentFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *comoponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:self];
    NSInteger year = [comoponents year];
    NSInteger month = [comoponents month] + 1;
    NSInteger day = [comoponents day];
    NSInteger hour = [comoponents hour];
    NSInteger minute = [comoponents minute];
    
    return [NSString stringWithFormat:@"%.4ld-%.2ld-%.2ld %.2ld:%.2ld", (long)year, (long)month, (long)day, (long)hour, (long)minute];
}



// return the time set for start hour. ie yyyy-mm-dd 00:00:00
-(NSDate*)getDayStartTime
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* strDate = [NSString stringWithFormat:@"%@ 00:00:00", [self toStringYMD]];
    NSDate *startDate = [formatter dateFromString:strDate];
    
    [formatter release];
    
    return startDate;
}

// return the time set for end hour, minute, secend. ie yyyy-mm-dd 23:59:59
-(NSDate*)getDayEndTime
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *strDate = [NSString stringWithFormat:@"%@ 23:59:59", [self toStringYMD]];
    NSDate *endDate = [formatter dateFromString:strDate];
    
    [formatter release];
    
    return endDate;
}

// offset day. ie self=2012-01-05 day=1 return 2012-01-06, self=2012-01-05 day=-1 return 2012-01-04.
-(NSDate*)offsetDay:(NSInteger)day
{
    NSTimeInterval interval = (86400.0*day);
    return [self dateByAddingTimeInterval:interval];
}

-(NSDate*)dateAfterMonth:(NSInteger)month
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setMonth:month];
    NSDate* date = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    [componentsToAdd release];
    return date;
}


@end
