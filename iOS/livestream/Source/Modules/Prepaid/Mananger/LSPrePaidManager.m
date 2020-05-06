//
//  LSPrePaidManager.m
//  livestream
//
//  Created by Calvin on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPrePaidManager.h"
#import "LSImManager.h"
#import "LSLoginManager.h"

@interface LSPrePaidManager()<IMManagerDelegate,IMLiveRoomManagerDelegate>

@end

@implementation LSPrePaidManager

- (void)dealloc {
    [[LSImManager manager] removeDelegate:self];
    [[LSImManager manager].client removeDelegate:self];
}

- (BOOL)addDelegate:(id<LSPrePaidManagerDelegate>)delegate {
    BOOL result = NO;
    @synchronized(self.delegates) {
        // 查找是否已存在
        for (NSValue *value in self.delegates) {
            id<LSPrePaidManagerDelegate> item = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                result = YES;
                break;
            }
        }
        // 未存在则添加
        if (!result) {
            [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
            result = YES;
        }
    }
    return result;
}

- (BOOL)removeDelegate:(id<LSPrePaidManagerDelegate>)delegate {
    BOOL result = NO;
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSPrePaidManagerDelegate> item = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                result = YES;
                break;
            }
        }
    }
    return result;
}

+ (instancetype)manager {
    static LSPrePaidManager *manager = nil;
    if (manager == nil) {
        manager = [[LSPrePaidManager alloc] init];
    }
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegates = [[NSMutableArray alloc] init];
        self.countriesArray = [NSArray array];
        self.creditsArray = [NSArray array];
        self.scheduleListConfirmedArray = [NSMutableArray array];
        self.scheduleListPendingdArray = [NSMutableArray array];
        [[LSImManager manager] addDelegate:self];
        [[LSImManager manager].client addDelegate:self];
    }
    return self;
}

- (void)removeScheduleListArray {
    [self.scheduleListConfirmedArray removeAllObjects];
    [self.scheduleListPendingdArray removeAllObjects];
}

//获取年月日
- (void)getDateData {
    NSMutableArray * dateArray = [NSMutableArray array];
         for (int i = 1; i < 14; i++) {
             NSInteger time = [[NSDate date] timeIntervalSince1970];
             time= time + 86400 * i;
              NSMutableArray * timeArray = [NSMutableArray array];
             for (int j = 0; j < 24; j++) {
                 NSString * str = @"";
                 if (j<10) {
                 str = [NSString stringWithFormat:@"0%d:00",j];
                 }else {
                     str = [NSString stringWithFormat:@"%d:00",j];
                 }
                 [timeArray addObject:str];
             }
             [dateArray addObject:@{@"year":[self getLocalTimeFromTimestamp:time timeFormat:@"MMM dd,yyyy"],@"time":timeArray}];
         }
    self.dateArray = dateArray;
}

- (NSArray *)getCreditArray {
    NSMutableArray * array = [NSMutableArray array];
    for (LSScheduleDurationItemObject * item in self.creditsArray) {
        
        if (item.credit != item.originalCredit) {
            NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits %0.2f Credits",item.duration,item.credit,item.originalCredit];
            NSString * str1 = [NSString stringWithFormat:@"%0.2f Credits",item.originalCredit];
             NSMutableAttributedString * attrStr =  [self newCreditsStr:str credits:str1];
            [array addObject:attrStr];
        }else {
            NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits",item.duration,item.credit];
             NSMutableAttributedString * attrStr =  [self newCreditsStr:str credits:@""];
            [array addObject:attrStr];
        }
    }
    return array;
}

- (NSArray *)getYearArray {
    NSMutableArray * array = [NSMutableArray array];
    for (NSDictionary * dic in self.dateArray) {
        if ([dic objectForKey:@"year"]) {
            [array addObject:[dic objectForKey:@"year"]];
        }
    }
    return array;
}

- (NSArray *)getTimeArray {
    NSMutableArray * array = [NSMutableArray array];
    for (int i = 0; i<self.dateArray.count; i++) {
        NSDictionary * dic = self.dateArray[i];
        NSString * year = [dic objectForKey:@"year"];
        if ([year isEqualToString:self.yaerStr]) {
            [array addObjectsFromArray:[dic objectForKey:@"time"]];
            break;
        }
    }
    
    return [self isDaylightSavingBenginTime:array];
}

#pragma mark - 请求数据
- (void)getCreditsData {
    LSGetScheduleDurationListRequest * request = [[LSGetScheduleDurationListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSScheduleDurationItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.creditsArray = array;
            }
        });
    };
    [[LSSessionRequestManager manager]sendRequest:request];
}


- (void)getCountryData {
    LSGetCountryTimeZoneListRequest * request = [[LSGetCountryTimeZoneListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSCountryTimeZoneItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.countriesArray = array;
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
    
    [self getCreditsData];
    
    [self getDateData];
}

#pragma mark - 发送预付费邀请
- (void)sendScheduleInvite:(LSScheduleInviteItem *)inviteItem {
    LSSendScheduleInviteRequest *request = [[LSSendScheduleInviteRequest alloc] init];
    request.type = inviteItem.type;
    request.refId = inviteItem.refId;
    request.anchorId = inviteItem.anchorId;
    request.timeZoneId = inviteItem.timeZoneItem.zoneId;
    request.startTime = inviteItem.startTime;
    request.duration = inviteItem.duration;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSSendScheduleInviteItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSPrePaidManager::LSSendScheduleInviteRequest( [发送预付费直播邀请] success: %@, errnum: %d, errmsg: %@, inviteId: %@, isSummerTime: %d )",BOOL2SUCCESS(success),errnum,errmsg,item.inviteId,item.isSummerTime);
            
            if (self.liveRoom && success) {
                ImScheduleMsgObject *msg = [[ImScheduleMsgObject alloc] init];
                msg.scheduleInviteId = item.inviteId;
                msg.status = IMSCHEDULESENDSTATUS_PENDING;
                msg.sendFlag = LSSCHEDULESENDFLAGTYPE_MAN;
                msg.duration = inviteItem.duration;
                msg.origintduration = inviteItem.duration;
                NSString *period = [self getStartTimeAndEndTomeFromTimestamp:item.startTime timeFormat:@"MMM dd, HH:00" isDaylightSaving:item.isSummerTime andZone:inviteItem.timeZoneItem.value];
                period = [NSString stringWithFormat:@"%@ %@(GMT %@)",period,inviteItem.timeZoneItem.city,inviteItem.timeZoneItem.value];
                msg.period = period;
                msg.startTime = item.startTime;
                msg.statusUpdateTime = item.addTime;
                msg.sendTime = item.addTime;
                msg.nickName = [LSLoginManager manager].loginItem.nickName;
                msg.fromId = [LSLoginManager manager].loginItem.userId;
                msg.toNickName = self.liveRoom.userName;
                
                ImScheduleRoomInfoObject *infoItem = [[ImScheduleRoomInfoObject alloc] init];
                infoItem.roomId = self.liveRoom.roomId;
                infoItem.nickName = self.liveRoom.userName;
                infoItem.toId = self.liveRoom.userId;
                infoItem.privScheId = item.inviteId;
                infoItem.msg = msg;
                [self sendScheduleNoticeServer:infoItem];
            }
            item.duration = inviteItem.duration;
            
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvSendScheduleInvite:errmsg:item:)]) {
                        [delegate onRecvSendScheduleInvite:errnum errmsg:errmsg item:item];
                    }
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

#pragma mark - 接受预付费邀请
- (void)sendAcceptScheduleInvite:(NSString *)inviteId duration:(int)duration infoObj:(LSScheduleInviteItem *)infoObj {
    LSAcceptScheduleInviteRequest *request = [[LSAcceptScheduleInviteRequest alloc] init];
    request.inviteId = inviteId;
    request.duration = duration;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSInteger statusUpdateTime) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSPrePaidManager::LSAcceptScheduleInviteRequest( [接收预付费直播邀请] success : %@, errnum : %d, errmsg : %@, statusUpdateTime : %ld)",BOOL2SUCCESS(success), errnum, errmsg, (long)statusUpdateTime);
            
            ImScheduleRoomInfoObject *infoItem = [[ImScheduleRoomInfoObject alloc] init];
            if (self.liveRoom && success) {
                ImScheduleMsgObject *msg = [[ImScheduleMsgObject alloc] init];
                msg.scheduleInviteId = inviteId;
                msg.status = IMSCHEDULESENDSTATUS_CONFIRMED;
                msg.sendFlag = LSSCHEDULESENDFLAGTYPE_MAN;
                msg.duration = duration;
                msg.origintduration = infoObj.origintduration;
                msg.period = infoObj.period;
                msg.startTime = infoObj.gmtStartTime;
                msg.statusUpdateTime = statusUpdateTime;
                msg.sendTime = infoObj.sendTime;
                msg.nickName = [LSLoginManager manager].loginItem.nickName;
                msg.fromId = [LSLoginManager manager].loginItem.userId;
                msg.toNickName = self.liveRoom.userName;
                
                infoItem.roomId = self.liveRoom.roomId;
                infoItem.nickName = self.liveRoom.userName;
                infoItem.toId = self.liveRoom.userId;
                infoItem.privScheId = inviteId;
                infoItem.msg = msg;
                [self sendScheduleNoticeServer:infoItem];
            }
            
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvSendAcceptSchedule:errmsg:statusUpdateTime:scheduleInviteId:duration:roomInfoItem:)]) {
                        [delegate onRecvSendAcceptSchedule:errnum errmsg:errmsg statusUpdateTime:statusUpdateTime scheduleInviteId:inviteId duration:duration roomInfoItem:infoItem];
                    }
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

#pragma mark - 拒绝预付费邀请
- (void)sendDeclinedScheduleInvite:(NSString *)inviteId {
    LSDeclinedScheduleInviteRequest *request = [[LSDeclinedScheduleInviteRequest alloc] init];
    request.inviteId = inviteId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSInteger statusUpdateTime) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSPrePaidManager::LSDeclinedScheduleInviteRequest( [拒绝预付费直播邀请] success : %@, errnum : %d, errmsg : %@, statusUpdateTime : %ld)",BOOL2SUCCESS(success), errnum, errmsg, (long)statusUpdateTime);
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvSendDeclinedSchedule:errmsg:statusUpdateTime:)]) {
                        [delegate onRecvSendDeclinedSchedule:errnum errmsg:errmsg statusUpdateTime:statusUpdateTime];
                    }
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

#pragma mark - 获取预付费直播列表
- (void)getScheduleList:(LSScheduleInviteStatus)status sendFlag:(LSScheduleSendFlagType)sendFlag anchorId:(NSString *)anchorId start:(int)start step:(int)step  {
    LSGetScheduleInviteListRequest *request = [[LSGetScheduleInviteListRequest alloc] init];
    request.status = status;
    request.sendFlag = sendFlag;
    request.anchorId = anchorId;
    request.start = start;
    request.step = step;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSScheduleInviteListItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSPrePaidManager::getScheduleList( [获取预付费直播列表] success : %@, errnum : %d, errmsg : %@, array : %lu)",BOOL2SUCCESS(success), errnum, errmsg, (unsigned long)array.count);
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvGetScheduleList:array:)]) {
                        [delegate onRecvGetScheduleList:errnum array:array];
                    }
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

#pragma mark - 获取预付费直播邀请详情
- (void)getScheduleDetail:(NSString *)inviteId {
    LSGetScheduleInviteDetailRequest *request = [[LSGetScheduleInviteDetailRequest alloc] init];
    request.inviteId = inviteId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSScheduleInviteDetailItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSPrePaidManager::getScheduleList( [获取预付费直播列表] success : %@, errnum : %d, errmsg : %@, anchorId : %@)",BOOL2SUCCESS(success), errnum, errmsg, item.anchorId);
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvGetScheduleDetail:item:)]) {
                        [delegate onRecvGetScheduleDetail:errnum item:item];
                    }
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

#pragma mark - 取消预付费预约
- (void)sendCancelScheduleInvite:(NSString *)inviteId {
    LSCancelScheduleInviteRequest *request = [[LSCancelScheduleInviteRequest alloc] init];
    request.inviteId = inviteId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSPrePaidManager::sendCancelScheduleInvite( [取消预付费预约] success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvSendScheduleInviteCancel:errmsg:)]) {
                        [delegate onRecvSendScheduleInviteCancel:errnum errmsg:errmsg];
                    }
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

#pragma mark - 预付费操作通知服务器
- (void)sendScheduleNoticeServer:(ImScheduleRoomInfoObject *)item {
    [[LSImManager manager] sendHandleSchedule:item];
}

#pragma mark - 接收预付费通知
- (void)onRecvHandleScheduleNotice:(ImScheduleRoomInfoObject *)item {
    NSLog(@"LSPrePaidManager::onRecvHandleScheduleNotice( [接收预付费操作] roomid : %@, privScheId : %@, sendFlag : %d, status : %d)",item.roomId, item.privScheId, item.msg.sendFlag, item.msg.status);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item.msg.sendFlag == LSSCHEDULESENDFLAGTYPE_ANCHOR && [item.roomId isEqualToString:self.liveRoom.roomId]) {
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onRecvAnchorSendScheduleNotice:)]) {
                        [delegate onRecvAnchorSendScheduleNotice:item];
                    }
                }
            }
        }
    });
}

#pragma mark - 获取某会话中预付费直播邀请列表
- (void)getScheduleRequestsList:(LSScheduleInviteType)type refId:(NSString *)refId{
    if (refId.length == 0) {
        return;
    }
    LSGetSessionInviteListRequest * request = [[LSGetSessionInviteListRequest alloc]init];
    request.refId = refId;
    request.type = type;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSScheduleLiveInviteItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
             NSLog(@"LSPrePaidManager::getScheduleRequestsList( [获取某会话中预付费直播邀请列表] success : %@, errnum : %d, errmsg : %@)",BOOL2SUCCESS(success), errnum, errmsg);
             
            NSInteger count = 0;
            NSInteger pcount = 0;
            if (array.count > 0 && success) {
                [self.scheduleListConfirmedArray removeAllObjects];
                [self.scheduleListPendingdArray removeAllObjects];
                for (LSScheduleLiveInviteItemObject * item in array) {
                    if (item.status == LSSCHEDULEINVITESTATUS_CONFIRMED) {
                        count++;
                        [self.scheduleListConfirmedArray addObject:item];
                    }else if (item.status == LSSCHEDULEINVITESTATUS_PENDING){
                        pcount++;
                        [self.scheduleListPendingdArray addObject:item];
                    }else {
                        
                    }
                }
            }
            @synchronized (self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSPrePaidManagerDelegate> delegate = (id<LSPrePaidManagerDelegate>)value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetScheduleListCount:confirmCount:pendingCount:)]) {
                        [delegate onGetScheduleListCount:count+pcount confirmCount:count pendingCount:pcount];
                    }
                }
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}
#pragma mark - 时间逻辑
//获取某个时区的当前时间
- (NSString *)getNewTimeZoneDate:(NSString *)gmtTime {
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMM dd,yyyy-HH:00"];
    dateFormat.timeZone = [NSTimeZone timeZoneWithAbbreviation:gmtTime];
    NSString * string = [dateFormat stringFromDate:[NSDate new]];
    
    if ([self nowtimeIsInBeginTime:string]) {
         NSInteger nowTime = [self timeSwitchTimestamp:string] + 3600;
        string= [self getTimeFromTimestamp:nowTime timeFormat:@"MMM dd,yyyy-HH:00" andZone:gmtTime];
    }
    return string;
}

//时间转字符串
- (NSDate *)stingDateToDate:(NSString *)string dateFormat:(NSString *)format andZone:(NSString*)zone{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:zone];
    return  [formatter dateFromString:string];
}

//根据时间转换本地时间
- (NSString *)getNowDateFromatAnDate:(NSDate *)anyDate {
     NSDateFormatter *format = [[NSDateFormatter alloc] init];
     format.dateFormat = @"MMM dd,yyyy-HH:mm";
     format.timeZone = [NSTimeZone localTimeZone];
     NSString *dateString = [format stringFromDate:anyDate];
    return dateString;
}
 
//时区格式
- (NSString *)getTimeZoneText:(LSTimeZoneItemObject*)item  {
    return [NSString stringWithFormat:@"(%@ %@)/%@",item.cityCode,item.value,item.city];
}

//获取本地时间戳
- (NSString *)getTimestampFromTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MMM dd,yyyy-HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone]; // 获得当前系统的时区
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

//获取当前时间
- (NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:00"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

//获取结束时间
- (NSString *)getEndTime:(NSString*)time {
    
    NSArray *array = [time componentsSeparatedByString:@":"];
    
    int beginTime = [[array firstObject] intValue] + 1;
    NSString * endTime = @"";
    if (beginTime == 24) {
        beginTime = 0;
    }
    if (beginTime < 10) {
        endTime = [NSString stringWithFormat:@"0%d:%@",beginTime,[array lastObject]];
    }else {
        endTime = [NSString stringWithFormat:@"%d:%@",beginTime,[array lastObject]];
    }
    return endTime;
}

//获取开始时间
- (NSString *)getBeginTime:(NSString*)time {
    NSArray *array = [time componentsSeparatedByString:@":"];
    int beginTime = [[array firstObject] intValue] - 1;
    NSString * endTime = @"";
    if (beginTime < 0) {
        beginTime = 0;
    }
    if (beginTime < 10) {
        endTime = [NSString stringWithFormat:@"0%d:%@",beginTime,[array lastObject]];
    }else {
        endTime = [NSString stringWithFormat:@"%d:%@",beginTime,[array lastObject]];
    }
    return endTime;
}

//时间戳转时间 zone不传默认0时区 
- (NSString *)getTimeFromTimestamp:(NSInteger)time timeFormat:(NSString *)format andZone:(NSString*)zone{
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    if (zone.length > 0) {
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:zone];
    }
    NSString *timeStr=[formatter stringFromDate:myDate];
    return timeStr;
}

//时间戳转本地时间
- (NSString *)getLocalTimeFromTimestamp:(NSInteger)time timeFormat:(NSString *)format{
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat = format;
    formatter.timeZone = [NSTimeZone localTimeZone];
    NSString *timeStr=[formatter stringFromDate:myDate];
    return timeStr;
}

//时间戳转GMT时间
- (NSString *)getGMTFromTimestamp:(NSInteger)time timeFormat:(NSString *)format{
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    formatter.dateFormat = format;
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSString *timeStr=[formatter stringFromDate:myDate];
    return timeStr;
}

- (NSString *)getStartTimeAndEndTomeFromTimestamp:(NSInteger)time timeFormat:(NSString *)format isDaylightSaving:(BOOL)isday andZone:(NSString*)zone {
    
    zone = [self getGMTTimeZone:zone];
    NSString * localBeginTime = [self getLocalTimeFromTimestamp:time timeFormat:format];
    if (zone.length > 0) {
        localBeginTime = [self getTimeFromTimestamp:time timeFormat:format andZone:zone];
    }
    
    NSArray * array = [localBeginTime componentsSeparatedByString:@", "];
    NSString * endTime = [self getEndTime:[array lastObject]];
    if (!isday) {
        return [NSString stringWithFormat:@"%@ - %@",localBeginTime,endTime];
    }
    
    localBeginTime = [NSString stringWithFormat:@"%@, %@",[array firstObject],endTime];
     NSString * dayEndTime = [self getEndTime:endTime];
    return  [NSString stringWithFormat:@"%@ - %@",localBeginTime,dayEndTime];
}

// 拼接时区
- (NSString *)getGMTTimeZone:(NSString *)zone {
    NSString *timeZone = @"";
    if (zone.length == 0) {
        return timeZone;
    }
    if (![zone containsString:@"GMT"]) {
        timeZone = [NSString stringWithFormat:@"GMT%@",zone];
    }
    
    if ([timeZone containsString:@":"]) {
        [timeZone stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    return timeZone;
}

//是否夏令时开始
- (NSArray *)isDaylightSavingBenginTime:(NSMutableArray *)array {
    
    NSMutableArray * dateArray = [NSMutableArray array];
    for (NSString * str in array) {
        [dateArray addObject:[NSString stringWithFormat:@"%@-%@",self.yaerStr,str]];
    }
    
    NSString *zone = [self getZone];
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:self.zoneItem.summerTimeStart];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd,yyyy-HH:00"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:zone];
    NSString *timeStr=[formatter stringFromDate:myDate];
    
    if ([dateArray containsObject:timeStr]) {
        NSInteger row = [dateArray indexOfObject:timeStr];
        [array removeObjectAtIndex:row];
    }
    return array;
}

- (NSString *)getSendRequestTime:(NSString *)format {
    NSString * time = [NSString stringWithFormat:@"%@-%@",self.yaerStr,self.benginTime];
    NSDate * date = [self stingDateToDate:time dateFormat:@"MMM dd,yyyy-HH:00" andZone:[self getZone]];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:[self getZone]];
    NSString *timeStr=[formatter stringFromDate:date];
    
    return timeStr;
    
}

- (NSString *)daylightSavingBeginTime:(NSString *)str {
    NSArray * array = [str componentsSeparatedByString:@"-"];
    str = [NSString stringWithFormat:@"%@-%@",[array firstObject],[self getBeginTime:[array lastObject]]];
    
    return str;
}

//获取时区
- (NSString*)getZone {
    NSString *zone = [self.zoneItem.value stringByReplacingOccurrencesOfString:@":" withString:@""];
    zone = [NSString stringWithFormat:@"GMT%@",zone];
    return zone;
}

//根据时间转时间戳
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime{
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM dd,yyyy-HH:mm"];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:[self getZone]];
    NSDate* date = [formatter dateFromString:formatTime];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return timeSp;
}

-(BOOL)nowtimeIsInBeginTime:(NSString *)time {
    NSInteger nowTime = [self timeSwitchTimestamp:time];
    if (self.zoneItem.summerTimeStart < nowTime && nowTime < self.zoneItem.summerTimeEnd) {
        return YES;
    }else {
        return NO;
    }
}


#pragma mark - 富文本
- (NSMutableAttributedString *)newTimeStr:(NSString *)str {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str attributes:@{
    NSForegroundColorAttributeName:
        [UIColor blackColor],
    NSFontAttributeName: [UIFont boldSystemFontOfSize:14]
    }];
    return attrStr;
}

- (NSMutableAttributedString *)newCreditsStr:(NSString *)str credits:(NSString*)creditsStr {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    if (creditsStr.length > 0) {
        [attrStr addAttributes:@{
                                NSStrikethroughStyleAttributeName:@(NSUnderlineStyleThick),
                                 NSForegroundColorAttributeName:
                                     [UIColor lightGrayColor],
                                 NSBaselineOffsetAttributeName:
                                     @(0),
                                 NSFontAttributeName: [UIFont fontWithName:@"Arial-BoldMT" size:14]
                                 } range:[str rangeOfString:creditsStr options:NSBackwardsSearch]];
    }
    return attrStr;
}

//发送Item
- (LSLCLiveChatScheduleMsgItemObject *)newSendMsgItemForm:(LSSendScheduleInviteItemObject *)item {
    LSLCLiveChatScheduleMsgItemObject * msgItem = [[LSLCLiveChatScheduleMsgItemObject alloc]init];
    msgItem.scheduleInviteId = item.inviteId;
    msgItem.type = SCHEDULEINVITE_PENDING;
    msgItem.timeZone = [NSString stringWithFormat:@"%@ (%@)",self.zoneItem.cityCode,self.zoneItem.value];
    msgItem.origintduration = item.duration;
    msgItem.startTime = item.startTime;
    msgItem.period = [NSString stringWithFormat:@"%@ - %@",[self getSendRequestTime:@"MMM dd, HH:00"], [self getEndTime:self.benginTime]];
    msgItem.sendTime = item.addTime;
    return msgItem;
}

// 获取直播间发送预付费邀请Item
- (ImScheduleRoomInfoObject *)getSendScheduleInviteMsg:(LSSendScheduleInviteItemObject *)item {
    ImScheduleRoomInfoObject *msgItem = [[ImScheduleRoomInfoObject alloc] init];
    msgItem.roomId = self.liveRoom.roomId;
    msgItem.nickName = self.liveRoom.userName;
    msgItem.toId = self.liveRoom.userId;
    msgItem.privScheId = item.inviteId;
    
    ImScheduleMsgObject *msg = [[ImScheduleMsgObject alloc] init];
    msg.scheduleInviteId = item.inviteId;
    msg.status = IMSCHEDULESENDSTATUS_PENDING;
    msg.origintduration = item.duration;
    msg.startTime = item.startTime;
    msg.sendTime = item.addTime;
    NSString *timeZone = [NSString stringWithFormat:@"%@ (%@)",self.zoneItem.cityCode,self.zoneItem.value];
    NSString *period = [NSString stringWithFormat:@"%@ - %@",[self getSendRequestTime:@"MMM dd, HH:00"], [self getEndTime:self.benginTime]];
    msg.period = [NSString stringWithFormat:@"%@%@",period,timeZone];
    
    msgItem.msg = msg;
    return msgItem;;
}
 
@end
