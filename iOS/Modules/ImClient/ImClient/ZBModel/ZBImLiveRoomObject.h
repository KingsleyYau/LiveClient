
//
//  ZBImLiveRoomObject.h
//  livestream
//
//  Created by Max on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

/**
 直播间Object
 */
@interface ZBImLiveRoomObject : NSObject

/**
 * 直播间结构体
 * anchorId                 主播ID
 * roomId                   直播间ID
 * roomType                 直播间类型
 * liveShowType             公开直播间类型（IMANCHORPUBLICROOMTYPE_COMMON：普通公开，IMANCHORPUBLICROOMTYPE_PROGRAM：节目）
 * pushUrl                  视频流url（字符串数组）
 * leftSeconds              开播前的倒数秒数（可无， 无或0表示立即开播）
 * maxFansiNum		        最大人数限制
 * pullUrl                  男士视频流url
 * status                   直播间状态（整型）（ZBLIVESTATUS_INIT：初始，ZBLIVESTATUSE_RECIPROCALSTART：开始倒数中，ZBLIVESTATUS_ONLINE：在线，ZBLIVESTATUS_ARREARAGE：欠费中，ZBLIVESTATUS_RECIPROCALEND：结束倒数中，ZBLIVESTATUS_CLOSE：关闭）
 */
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, assign) ZBRoomType roomType;
@property (nonatomic, assign) IMAnchorPublicRoomType liveShowType;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull pushUrl;
@property (nonatomic, assign) int leftSeconds;
@property (nonatomic, assign) int maxFansiNum;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull pullUrl;
@property (nonatomic, assign) ZBLiveStatus status;

@end
