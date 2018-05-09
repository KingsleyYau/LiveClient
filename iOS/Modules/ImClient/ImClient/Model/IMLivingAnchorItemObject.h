
//
//  IMLivingAnchorItemObject.h
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

@interface IMLivingAnchorItemObject : NSObject

/**
 * 直播间中的主播列表
 * @anchorId                主播ID
 * @nickName                主播昵称
 * @photoUrl                主播头像url
 * @anchorStatus            主播状态（LIVEANCHORSTATUS_INVITATION：邀请中，LIVEANCHORSTATUS_INVITECONFIRM：邀请已确认，LIVEANCHORSTATUS_KNOCKCONFIRM：敲门已确认，LIVEANCHORSTATUS_RECIPROCALENTER：倒数进入中，LIVEANCHORSTATUS_ONLINE：在线）
 * @inviteId                邀请ID（可无，仅当anchor_status=LIVEANCHORSTATUS_INVITATION时存在）
 * @leftSeconds             倒数秒数（整型）（可无，仅当anchor_status=3时存在）
 * @loveLevel               与观众的私密等级
 * @videoUrl                主播视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》
 */
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, assign) LiveAnchorStatus anchorStatus;
@property (nonatomic, copy) NSString *_Nonnull  inviteId;
@property (nonatomic, assign) int leftSeconds;
@property (nonatomic, assign) int loveLevel;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull videoUrl;

@end
