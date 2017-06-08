//
//  NSDate+ToString.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ToString)
// NSDate to NSString. ie hh:mm
-(NSString*)toStringHM;
// NSDate to NSString. ie mm-dd
-(NSString*)toStringMD;
// NSDate to NSString. ie mm-dd
-(NSString*)toStringMDCH;
// NSDate to NSString. ie m-d hh:mm
-(NSString*)toStringMDHM;
// NSDate to NSString. ie yyyy-mm-dd
-(NSString*)toStringYMD;
// NSDate to NSString. ie yyyy-mm-dd hh:mm:ss
-(NSString*)toStringYMDHMS;
// NSDate to NSString. ie yyyy-mm-dd hh:mm
-(NSString*)toStringYMDHM;
// NSDate to NSString. ie yy-mm-dd hh:mm
-(NSString*)toString2YMDHM;
// NsDate to NSString. ie if(today){ hh:mm } else { yy-mm-dd }
-(NSString*)toStringToday;
/** CrashFileDate */
-(NSString*)toStringCrashDate;
/** CrashZipDate */
-(NSString*)toStringCrashZipDate;

// return the time set for start hour. ie yyyy-mm-dd 00:00:00
-(NSDate*)getDayStartTime;
// return the time set for end hour, minute, secend. ie yyyy-mm-dd 23:59:59
-(NSDate*)getDayEndTime;

- (NSString *)dateStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

// offset day. ie self=2012-01-05 day=1 return 2012-01-06, self=2012-01-05 day=-1 return 2012-01-04.
-(NSDate*)offsetDay:(NSInteger)day;

-(NSDate*)dateAfterMonth:(NSInteger)month;
@end
