//
//  MsgItem.h
//  livestream
//
//  Created by Max on 2017/5/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYText.h>
#import "LSImManager.h"
#import "LiveRoom.h"

typedef enum {
    MsgType_Chat,
    MsgType_Gift,
    MsgType_Announce,
    MsgType_Link,
    MsgType_Share,
    MsgType_Join,
    MsgType_RiderJoin,
    MsgType_Warning,
    MsgType_Recommend, // 邀请消息
    MsgType_Knock, // 主播敲门
    MsgType_Talent,
    MsgType_FirstFree, // 试聊卷
    MsgType_Public_FirstFree, // 公开试聊卷
    MsgType_Schedule,  // 预付费消息
    MsgType_Schedule_Status_Tip // 预付费回复状态消息
} MsgType;

typedef enum {
    UsersType_Me,
    UsersType_Audience,
    UsersType_Liver
} UsersType;

typedef enum {
    ScheduleType_Pending,
    ScheduleType_Confirmed,
    ScheduleType_Declined
} ScheduleType;

@interface MsgItem : NSObject
/** 文本消息Id **/
@property (nonatomic, assign) NSInteger msgId;

/** 文本消息类型 **/
@property (nonatomic, assign) MsgType msgType;
/** 发送文本用户类型 **/
@property (nonatomic, assign) UsersType usersType;
/** 礼物类型文本 **/
@property (nonatomic, assign) GiftType giftType;
/** 预付费请求状态 **/
@property (nonatomic, assign) ScheduleType scheduleType;

/** 勋章url **/
@property (nonatomic, copy) NSString *honorUrl;
/** 发送方昵称 **/
@property (nonatomic, copy) NSString *sendName;
/** 接收方昵称 **/
@property (nonatomic, copy) NSString *toName;
/** 接收方名字数组 **/
@property (nonatomic, strong) NSMutableArray *nameArray;
/** 座驾名称 **/
@property (nonatomic, copy) NSString *riderName;
/** 接收文本消息 **/
@property (nonatomic, copy) NSString *text;
/** link公告url **/
@property (nonatomic, copy) NSString *linkStr;
/** 是否购票 **/
@property (nonatomic, assign) BOOL isHasTicket;
/** 直播间免费时长 **/
@property (nonatomic, assign) int freeSeconds;
/** 直播间资费 **/
@property (nonatomic, assign) CGFloat roomPrice;

/** 礼物图片url **/
@property (nonatomic, copy) NSString *smallImgUrl;
/** 礼物名称 **/
@property (nonatomic, copy) NSString *giftName;
/** 礼物个数 **/
@property (nonatomic, assign) int giftNum;

/** 拼接文本消息 **/
@property (nonatomic, copy) NSMutableAttributedString *attText;

/** 推荐主播对象 **/
@property (nonatomic, strong) IMRecommendHangoutItemObject *recommendItem;
/** 敲门对象 **/
@property (nonatomic, strong) IMKnockRequestItemObject *knockItem;

/** 文本layout **/
@property (nonatomic, strong) YYTextLayout *layout;
/** 文本高度 **/
@property (nonatomic, assign) CGFloat containerHeight;
/** 文本frame值 **/
@property (nonatomic, assign) CGRect labelFrame;
/** 预付费消息数据 **/
@property (nonatomic, strong) ImScheduleRoomInfoObject *scheduleMsg;

// 用于判断预付费消息是否展开
@property (nonatomic, assign) BOOL isScheduleMore;
// 用于判断预付费消息是否最小化
@property (nonatomic, assign) BOOL isMinimu;

@end
