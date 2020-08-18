//
//  LSPrePaidManager.h
//  livestream
//
//  Created by Calvin on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSTimeZoneItemObject.h"
#import "LSCountryTimeZoneItemObject.h"
#import "LSScheduleInviteItem.h"

#import "LSGetCountryTimeZoneListRequest.h"
#import "LSGetScheduleDurationListRequest.h"
#import "LSAcceptScheduleInviteRequest.h"
#import "LSDeclinedScheduleInviteRequest.h"
#import "LSSendScheduleInviteRequest.h"
#import "LSGetScheduleInviteListRequest.h"
#import "LSGetScheduleInviteDetailRequest.h"
#import "LSGetSessionInviteListRequest.h"
#import "LSCancelScheduleInviteRequest.h"
#import "GetActivityTimeRequest.h"
#import "LiveRoom.h"

#import "LSLCLiveChatScheduleMsgItemObject.h"

@protocol LSPrePaidManagerDelegate <NSObject>
@optional;
/* 接收发送预付费直播邀请回调 */
- (void)onRecvSendScheduleInvite:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg item:(LSSendScheduleInviteItemObject *)item refId:(NSString *)refId;
/* 接收接受预付费邀请回调 */
- (void)onRecvSendAcceptSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString*)inviteId duration:(int)duration roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem;
/* 接收拒绝预付费邀请回调 */
- (void)onRecvSendDeclinedSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime;
/* 接收获取预付费直播列表回调 */
- (void)onRecvGetScheduleList:(HTTP_LCC_ERR_TYPE)errnum array:(NSArray<LSScheduleInviteListItemObject *> *)array;
/* 接收获取预付费直播邀请详情回调 */
- (void)onRecvGetScheduleDetail:(HTTP_LCC_ERR_TYPE)errnum item:(LSScheduleInviteDetailItemObject *)item;
/* 接收女士发送预付费消息通知 */
- (void)onRecvAnchorSendScheduleNotice:(ImScheduleRoomInfoObject *)item;
/* 接收预付费列表数 */
- (void)onGetScheduleList:(BOOL)success maxCount:(NSInteger)maxCount confirmCount:(NSInteger)count pendingCount:(NSInteger)pCount refId:(NSString *)refId;
/* 接收取消预约回调 */
- (void)onRecvSendScheduleInviteCancel:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg;
/* 接收日期回调 */
- (void)onRecvScheduleGetDateData;
@end

@interface LSPrePaidManager : NSObject

+ (instancetype)manager;

//国家时区数组
@property (nonatomic, strong) NSArray * countriesArray;
//日期数组
@property (nonatomic, strong) NSArray * dateArray;
//开始时间数组
@property (nonatomic, strong) NSArray * beginTimeArray;
//时长价格数组
@property (nonatomic, strong) NSArray * creditsArray;
//选择的时区
@property (nonatomic, strong) LSTimeZoneItemObject * zoneItem;
//选择的时长
@property (nonatomic, copy) NSString * duration;
//选择的日期
@property (nonatomic, copy) NSString * yaerStr;
//开始时间
@property (nonatomic,copy) NSString * benginTime;

@property (nonatomic, assign) NSInteger activityTime;

@property (nonatomic, strong) LiveRoom *liveRoom;

//某个会话/直播间/邮件的邀请列表数组
@property (nonatomic, strong) NSMutableArray * scheduleListConfirmedArray;
@property (nonatomic, strong) NSMutableArray * scheduleListPendingdArray;

// 代理数组
@property (nonatomic, strong) NSMutableArray *delegates;

- (BOOL)addDelegate:(id<LSPrePaidManagerDelegate>)delegate;
- (BOOL)removeDelegate:(id<LSPrePaidManagerDelegate>)delegate;

- (void)removeScheduleListArray;
- (void)getCountryData;
- (void)getDateData;

//获取时长价格数组
- (NSArray *)getCreditArray;
//获取年月数组
- (NSArray *)getYearArray;
//获取开始时间数组
- (NSArray *)getTimeArray;

//时长和价格富文本
- (NSMutableAttributedString *)newCreditsStr:(NSString *)str credits:(NSString*)creditsStr;

//拼接时区格式
- (NSString *)getTimeZoneText:(LSTimeZoneItemObject*)item;
//获得时区  例：GMT+0000
- (NSString*)getZone;

//获取某个时区的24小时后时间
- (NSString *)get24TimeZoneDate:(NSString *)gmtTime;
//根据时间转换本地时间
- (NSString *)getNowDateFromatAnDate:(NSDate *)anyDate;
 
//是否在夏令时时间内
-(BOOL)nowtimeIsInBeginTime:(NSString *)time;
//夏令时增加1个小时
- (NSString *)daylightSavingBeginTime:(NSString *)str;
//根据开始时间获得结束时间
- (NSString *)getEndTime:(NSString*)time;


//时间格式转字符串
- (NSDate *)stingDateToDate:(NSString *)string dateFormat:(NSString *)format andZone:(NSString*)zone;


//时间戳转时间 zone不传默认0时区 format格式： MMM dd, HH:00 zone格式: @"GMT+0800"
- (NSString *)getTimeFromTimestamp:(NSInteger)time timeFormat:(NSString *)format andZone:(NSString*)zone;
//时间戳转本地时间
- (NSString *)getLocalTimeFromTimestamp:(NSInteger)time timeFormat:(NSString *)format;
//时间戳转GMT时间
- (NSString *)getGMTFromTimestamp:(NSInteger)time timeFormat:(NSString *)format;

//时间戳转时间 format格式： MMM dd, HH:00,返回 MMM dd, HH:00 - HH:00 并判断是否夏令时 zone格式: @"GMT+0800"
- (NSString *)getStartTimeAndEndTomeFromTimestamp:(NSInteger)time timeFormat:(NSString *)format isDaylightSaving:(BOOL)isday andZone:(NSString*)zone;

- (NSString*)getLocalTimeBeginTiemAndEndTimeFromTimestamp:(NSInteger)time timeFormat:(NSString *)format ;

//获取详情显示时间 format格式： MMM dd,YYYY HH:00,返回 MMM dd,YYYY HH:00 - HH:00 并判断是否夏令时 zone格式: @"GMT+0800"
- (NSString *)getDetailStartAndEndTimestamp:(NSInteger)time timeFormat:(NSString *)format isDaylightSaving:(BOOL)isday andZone:(NSString*)zone;

//根据时间转时间戳
-(NSInteger)timeSwitchTimestamp:(NSString *)formatTime;

//获取接口需要的时间格式数据
- (NSString *)getSendRequestTime:(NSString *)format;
// 发送预付费邀请
- (void)sendScheduleInvite:(LSScheduleInviteItem *)inviteItem;
// 接收预付费邀请
- (void)sendAcceptScheduleInvite:(NSString *)inviteId duration:(int)time infoObj:(LSScheduleInviteItem *)infoObj;
// 拒绝预付费邀请
- (void)sendDeclinedScheduleInvite:(NSString *)inviteId;
// 获取预付费邀请列表
- (void)getScheduleList:(LSScheduleInviteStatus)status sendFlag:(LSScheduleSendFlagType)sendFlag anchorId:(NSString *)anchorId start:(int)start step:(int)step;
// 获取预付费详情
- (void)getScheduleDetail:(NSString *)inviteId;
//获取某会话中预付费直播邀请列表
- (void)getScheduleRequestsList:(LSScheduleInviteType)type refId:(NSString *)refId;
// 取消预付费预约
- (void)sendCancelScheduleInvite:(NSString *)inviteId;
//发送Item
- (LSLCLiveChatScheduleMsgItemObject *)newSendMsgItemForm:(LSSendScheduleInviteItemObject *)item;
// 获取直播间发送预付费邀请Item
- (ImScheduleRoomInfoObject *)getSendScheduleInviteMsg:(LSSendScheduleInviteItemObject *)item;

@end

 
