
//
//  AnchorHangoutRoomItemObject.h
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnchorRecvGiftItemObject.h"
#import "OtherAnchorItemObject.h"

@interface AnchorHangoutRoomItemObject : NSObject

/**
 * 互动直播间
 * @roomId                  直播间ID
 * @roomType                直播间类型（参考《“直播间类型”对照表》）
 * @manId                   观众ID
 * @manNickName             观众昵称ID
 * @manPhotoUrl             观众头像url
 * @manLevel                观众等级
 * @manVideoUrl             观众视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
 * @pushUrl                 视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》）
 * @otherAnchorList         其它主播列表
 * @buyforList              已收礼物列表
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, assign) ZBRoomType roomType;
@property (nonatomic, copy) NSString *_Nonnull manId;
@property (nonatomic, copy) NSString *_Nonnull manNickName;
@property (nonatomic, copy) NSString *_Nonnull manPhotoUrl;
@property (nonatomic, assign) int manLevel;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull manVideoUrl;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull pushUrl;
@property (nonatomic, strong) NSArray<OtherAnchorItemObject *> *_Nonnull otherAnchorList;
@property (nonatomic, strong) NSArray<AnchorRecvGiftItemObject *> *_Nonnull buyforList;


@end
