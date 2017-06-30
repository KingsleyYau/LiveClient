//
//  LiveRoomGiftItemObject.h
//  dating
//
//  Created by Alex on 17/5/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <httpcontroller/HttpRequestEnum.h>

@interface LiveRoomGiftItemObject : NSObject
/* 礼物ID */
@property (nonatomic, strong) NSString* giftId;
/* 礼物名字 */
@property (nonatomic, strong) NSString* name;
/* 礼物小图标（用于文本聊天窗显示） */
@property (nonatomic, strong) NSString*  smallImgUrl;
/* 发送列表显示的图片url */
@property (nonatomic, strong) NSString*  imgUrl;
/* 礼物在直播间显示的资源url */
@property (nonatomic, strong) NSString*  srcUrl;
/* 发送礼物所需的金币 */
@property (nonatomic, assign) double coins;
/* 是否可连击（1：是 0:否， ，默认：0 ） （仅type ＝ 1有效） */
@property (nonatomic, assign) BOOL multi_click;
/* 礼物类型（1: 普通礼物 2：高级礼物（动画）） */
@property (nonatomic, assign) GiftType type;
/* 礼物最后更新时间戳（1970年起的秒数） */
@property (nonatomic, assign) int update_time;
@end
