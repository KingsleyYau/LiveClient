//
//  ImBookingReplyObject.h
//  dating
//
//  Created by Alex on 17/09/12.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

/**
 * 预约私密邀请回复知结构体
 * inviteId                 邀请ID
 * replyType                主播回复（0:拒绝 1:同意）
 * roomId                   直播间ID
 * anchorId                 主播ID
 * nickName                 主播昵称
 * avatarImg                主播头像url
 * msg                      提示文字
 */
@interface ImBookingReplyObject : NSObject
@property (nonatomic, copy) NSString* _Nullable inviteId;
@property (nonatomic, assign) ReplyType replyType;
@property (nonatomic, copy) NSString* _Nullable roomId;
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, copy) NSString* _Nullable nickName;
@property (nonatomic, copy) NSString* _Nullable avatarImg;
@property (nonatomic, copy) NSString* _Nullable msg;

@end
