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
    MsgType_FirstFree // 试聊卷
} MsgType;

typedef enum {
    UsersType_Me,
    UsersType_Audience,
    UsersType_Liver
} UsersType;

@interface MsgItem : NSObject
/** 文本消息类型 **/
@property (assign) MsgType msgType;
/** 发送文本用户类型 **/
@property (assign) UsersType usersType;
/** 礼物类型文本 **/
@property (assign) GiftType giftType;

/** 勋章url **/
@property (strong) NSString *honorUrl;
/** 发送方昵称 **/
@property (strong) NSString *sendName;
/** 接收方昵称 **/
@property (strong) NSString *toName;
/** 接收方名字数组 **/
@property (strong) NSMutableArray *nameArray;
/** 座驾名称 **/
@property (strong) NSString *riderName;
/** 接收文本消息 **/
@property (strong) NSString *text;
/** link公告url **/
@property (strong) NSString *linkStr;
/** 是否购票 **/
@property (nonatomic, assign) BOOL isHasTicket;

/** 礼物图片url **/
@property (strong) NSString *smallImgUrl;
/** 礼物名称 **/
@property (strong) NSString *giftName;
/** 礼物个数 **/
@property (nonatomic, assign) int giftNum;

/** 拼接文本消息 **/
@property (strong) NSMutableAttributedString *attText;

/** 推荐主播对象 **/
@property (strong, nonatomic) IMRecommendHangoutItemObject *recommendItem;
/** 敲门对象 **/
@property (strong, nonatomic) IMKnockRequestItemObject *knockItem;

/** 文本layout **/
@property (nonatomic, strong) YYTextLayout *layout;
/** 文本高度 **/
@property (nonatomic, assign) CGFloat containerHeight;
/** 文本frame值 **/
@property (nonatomic, assign) CGRect labelFrame;

@end
