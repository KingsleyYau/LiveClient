//
//  LSDateTool.m
//  livestream
//
//  Created by Randy_Fan on 2018/9/19.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSDateTool.h"

#define kMinuteTimeInterval (60)
#define kHourTimeInterval   (60 * kMinuteTimeInterval)
#define kDayTimeInterval    (24 * kHourTimeInterval)
#define kTwoDayTimeInterval (2  * kDayTimeInterval)
#define kWeekTimeInterval   (7  * kDayTimeInterval)
#define kMonthTimeInterval  (30 * kDayTimeInterval)
#define kThreeMonthTimeInterval  (90 * kDayTimeInterval)
#define kYearTimeInterval   (12 * kMonthTimeInterval)

@implementation LSDateTool

- (BOOL)isToday:(NSDate *)date {
    // 是否是今天
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return YES;
    }
    return NO;
}

- (BOOL)isYesterday:(NSDate *)date {
    // 是否是昨天
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    NSDate *yesterday = [today dateByAddingTimeInterval: -kDayTimeInterval];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([yesterday isEqualToDate:otherDate]) {
        return YES;
    }
    return NO;
    
}

- (BOOL)isBeforeYesterday:(NSDate *)date {
    // 是否是前天
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    NSDate *yesterday = [today dateByAddingTimeInterval: -kDayTimeInterval * 2];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([yesterday isEqualToDate:otherDate]) {
        return YES;
    }
    return NO;
}

- (NSString *)showMessageListTimeTextOfDate:(NSDate *)date {
    
    NSString *showTimeStr = nil;
    
    NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
    interval = -interval;
    
    if ([self isToday:date]) {
        // 今天的消息
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        showTimeStr = [dateFormat stringFromDate:date];
        
    } else if ([self isYesterday:date]) {
        
        showTimeStr = NSLocalizedString(@"Yesterday", @"Yesterday");

    } else if (interval > kTwoDayTimeInterval && interval <= kWeekTimeInterval) {
        // 前天
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"cccc"];
        showTimeStr = [dateFormat stringFromDate:date];
        
    } else if (interval > kWeekTimeInterval && interval < kThreeMonthTimeInterval) {
        // 最近一周
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMM dd,yyyy"];
        showTimeStr = [dateFormat stringFromDate:date];
    } else {
        showTimeStr = @"";
    }
    return showTimeStr;
}

- (NSString *)showChatListTimeTextOfDate:(NSDate *)date {
    NSString *showTimeStr = nil;
    
    NSTimeInterval interval = [date timeIntervalSinceDate:[NSDate date]];
    interval = -interval;
    
    if ([self isToday:date]) {
        // 今天的消息
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        showTimeStr = [dateFormat stringFromDate:date];
        
    } else if ([self isYesterday:date]) {
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSString *timeStr = [dateFormat stringFromDate:date];
        showTimeStr = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Yesterday", @"Yesterday"), timeStr];
        
    } else if ([self isBeforeYesterday:date] && interval <= kWeekTimeInterval) {
        // 前天
        NSDateFormatter* dayFormat = [[NSDateFormatter alloc] init];
        [dayFormat setDateFormat:@"cccc"];
        NSString *dayStr = [dayFormat stringFromDate:date];
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSString *timeStr = [dateFormat stringFromDate:date];
        
        showTimeStr = [NSString stringWithFormat:@"%@ %@",dayStr, timeStr];
        
    } else {
        // 最近一周
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY/MM/dd HH:mm"];
        showTimeStr = [dateFormat stringFromDate:date];
    }
    return showTimeStr;
}

- (NSString *)showMailListTimeTextOfDate:(NSDate *)date {
    NSString *showTimeStr = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear;
    // 获得当前时间的
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    // 获得消息时间
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *usLoacal = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:usLoacal];
    // 判断是否是今年
    if (selfCmps.year == nowCmps.year) {
        [dateFormat setDateFormat:@"MM dd"];
    } else {
        [dateFormat setDateFormat:@"MM dd,YYYY"];
    }
    showTimeStr = [dateFormat stringFromDate:date];
    return showTimeStr;
}


- (NSString *)showSayHiListTimeTextOfDate:(NSDate *)date {
    NSString *showTimeStr = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear;
    // 获得当前时间的
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    // 获得消息时间
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *usLoacal = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:usLoacal];
    // 判断是否是今年
    if (selfCmps.year == nowCmps.year) {
        [dateFormat setDateFormat:@"MMMM dd"];
    } else {
        [dateFormat setDateFormat:@"MMMM dd,YYYY"];
    }
    showTimeStr = [dateFormat stringFromDate:date];
    return showTimeStr;
}


- (NSString *)showGreetingDetailTimeOfDate:(NSDate *)date {
    NSString *showTimeStr = nil;
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd,YYYY"];
    showTimeStr = [dateFormat stringFromDate:date];
    return showTimeStr;
}

@end
