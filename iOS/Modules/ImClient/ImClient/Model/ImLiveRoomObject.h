
//
//  ImLiveRoomObject.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RebateInfoObject.h"
#include "IImClientDef.h"

/**
 直播间Object
 */
@interface ImLiveRoomObject : NSObject

/**
 * 礼物列表结构体
 * userId                   主播ID
 * nickName                 主播昵称
 * roomId                   主播ID
 * photoUrl                 主播头像url
 * videoUrls                 视频流url
 * roomType                 直播间类型
 * credit                   信用点
 * usedVoucher              是否使用使用劵（0:否 1:是）
 * fansNum                  观众人数
 * emoTypeList		        可发送文本表情类型列表
 * loveLevel                亲密度等级
 * rebateInfo               返点信息
 * favorite                 是否已收藏（0:否 1:是  默认：1）（可无）
 * leftSeconds              开播前的倒数秒数（可无， 无或0表示立即开播）
 * waitStart		        是否要等开播通知（0:否 1:是 默认：0  直至收到《直播间开播通知》）
 * manPushUrl               男士视频流url
 * manlevel                 男士等级
 * roomPrice                直播间资费
 * manPushPrice             视频资费
 * maxFansiNum		        最大人数限制
 * honorId                  勋章ID
 * honorImg                 勋章图片url
 */
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull videoUrls;
@property (nonatomic, assign) RoomType roomType;
@property (nonatomic, assign) double credit;
@property (nonatomic, assign) BOOL usedVoucher;
@property (nonatomic, assign) int fansNum;
@property (nonatomic, strong) NSArray<NSNumber *> *_Nonnull emoTypeList;
@property (nonatomic, assign) int loveLevel;
@property (nonatomic, strong) RebateInfoObject *_Nonnull rebateInfo;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) int leftSeconds;
@property (nonatomic, assign) BOOL waitStart;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull manPushUrl;
@property (nonatomic, assign) int manLevel;
@property (nonatomic, assign) double roomPrice;
@property (nonatomic, assign) double manPushPrice;
@property (nonatomic, assign) int maxFansiNum;
@property (nonatomic, copy) NSString *_Nonnull honorId;
@property (nonatomic, copy) NSString *_Nonnull honorImg;

@end
