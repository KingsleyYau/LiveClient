
//
//  OtherAnchorItemObject.h
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

@interface OtherAnchorItemObject : NSObject

/**
 * 其它主播列表
 * @anchorId                主播ID
 * @nickName                主播昵称
 * @photoUrl                主播头像url
 * @anchorStatus            主播状态（0：邀请中，1：邀请已确认，2：敲门已确认，3：倒数进入中，4：在线）
 * @leftSeconds             倒数秒数（整型）（可无，仅当anchor_status=3时存在）
 * @loveLevel               与观众的私密等级
 * @videoUrl                主播视频流url（字符串数组）（访问视频URL的协议参考《“视频URL”协议描述》
 */
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, assign) AnchorStatus anchorStatus;
@property (nonatomic, assign) int leftSeconds;
@property (nonatomic, assign) int loveLevel;
@property (nonatomic, strong) NSArray<NSString *> *_Nonnull videoUrl;

@end
