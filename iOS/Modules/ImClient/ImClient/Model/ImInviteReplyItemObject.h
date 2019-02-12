
//
//  ImInviteReplyItemObject.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImAuthorityItemObject.h"
#include "IImClientDef.h"

/**
  立即私密邀请回复Object
 */
@interface ImInviteReplyItemObject : NSObject

/**
 * 立即私密邀请回复
 *  @inviteId      邀请ID
 *  @replyType     主播回复 （0:拒绝 1:同意）
 *  @roomId        直播间ID （可无，m_replyType ＝ 1存在）
 *  @roomType      直播间类型
 *  @anchorId      主播ID
 *  @nickName      主播昵称
 *  @avatarImg     主播头像
 *  @msg           提示文字
 *  @chatOnlineStatus  Chat在线状态（IMCHATONLINESTATUS_OFF：离线，IMCHATONLINESTATUS_ONLINE：在线）
 *  @priv         权限
 */
@property (nonatomic, copy) NSString* inviteId;
@property (nonatomic, assign) ReplyType replyType;
@property (nonatomic, copy) NSString* roomId;
@property (nonatomic, assign) RoomType roomType;
@property (nonatomic, copy) NSString* anchorId;
@property (nonatomic, copy) NSString* nickName;
@property (nonatomic, copy) NSString* avatarImg;
@property (nonatomic, copy) NSString* msg;
@property (nonatomic, assign) IMChatOnlineStatus status;
@property (nonatomic, strong) ImAuthorityItemObject* priv;

@end
