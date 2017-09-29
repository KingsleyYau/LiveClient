//
//  GiftInfoItemObject.h
//  dating
//
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface GiftInfoItemObject : NSObject
/**
 * 获取礼物列表成功结构体
 * giftId			礼物ID
 * name				礼物名字
 * smallImgUrl       礼物小图标（用于文本聊天窗显示）
 * middleImgUrl      礼物中图标（用于发送列表显示）
 * bigImgUrl         礼物大图标（用于播放连击显示）
 * srcFlashUrl	    礼物在直播间显示／播放的flash资源url
 * srcwebpUrl		礼物在直播间显示／播放的webp资源url
 * credit		    发送礼物所需的信用点
 * multiClick		是否可连击（1：是 0:否， ，默认：0 ） （仅type ＝ 1有效）
 * type			    礼物类型（1: 普通礼物 2：高级礼物（动画））
 * level			    发送礼物的用户限制等级，发送者等级>= 礼物等级才能发送
 * loveLevel			发送礼物的亲密度限制，发送者亲密度>= 礼物亲密度才能发送
 * sendNumList       发送可选数量列表
 * update_time		礼物最后更新时间戳（1970年起的秒数）
 * playTime         大礼物的swf播放时长（毫秒）
 */

/* 礼物ID */
@property (nonatomic, copy) NSString* giftId;
/* 礼物名字 */
@property (nonatomic, copy) NSString* name;
/* 礼物小图标（用于文本聊天窗显示） */
@property (nonatomic, copy) NSString*  smallImgUrl;
/* 礼物中图标（用于发送列表显示） */
@property (nonatomic, copy) NSString*  middleImgUrl;
/* 礼物大图标（用于播放连击显示） */
@property (nonatomic, copy) NSString*  bigImgUrl;
/* 礼物在直播间显示／播放的flash资源url */
@property (nonatomic, copy) NSString*  srcFlashUrl;
/* 礼物在直播间显示／播放的webp资源url */
@property (nonatomic, copy) NSString*  srcwebpUrl;
/* 发送礼物所需的信用点 */
@property (nonatomic, assign) double credit;
/* 是否可连击（1：是 0:否， ，默认：0 ） （仅type ＝ 1有效） */
@property (nonatomic, assign) BOOL multiClick;
/* 礼物类型（1: 普通礼物 2：高级礼物（动画）） */
@property (nonatomic, assign) GiftType type;
/* 发送礼物的用户限制等级，发送者等级>= 礼物等级才能发送 */
@property (nonatomic, assign) int level;
/* 发送礼物的亲密度限制，发送者亲密度>= 礼物亲密度才能发送 */
@property (nonatomic, assign) int loveLevel;
/* 发送可选数量列表 */
@property (nonatomic, strong) NSMutableArray<NSNumber *>* sendNumList;
/* 礼物最后更新时间戳（1970年起的秒数） */
@property (nonatomic, assign) NSInteger updateTime;
/* 大礼物的swf播放时长（毫秒） */
@property (nonatomic, assign) int playTime;
@end
