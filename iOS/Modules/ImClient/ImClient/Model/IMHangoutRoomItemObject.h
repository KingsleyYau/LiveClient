
//
//  IMHangoutRoomItemObject.h
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMRecvGiftItemObject.h"
#import "IMLivingAnchorItemObject.h"

@interface IMHangoutRoomItemObject : NSObject

/**
 * 互动直播间
 * @roomId                  直播间ID
 * @roomType                直播间类型（参考《“直播间类型”对照表》）
 * @manLevel                观众等级
 * @manPushPrice            视频资费
 * @credit                  当前信用点余额
 * @pushUrl                 视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
 * @otherAnchorList         其它主播列表
 * @buyforList              已收礼物列表
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, assign) RoomType roomType;
@property (nonatomic, assign) int manLevel;
@property (nonatomic, assign) double manPushPrice;
@property (nonatomic, assign) double credit;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull pushUrl;
@property (nonatomic, strong) NSArray<IMLivingAnchorItemObject *> *_Nonnull otherAnchorList;
@property (nonatomic, strong) NSArray<IMRecvGiftItemObject *> *_Nonnull buyforList;


@end
