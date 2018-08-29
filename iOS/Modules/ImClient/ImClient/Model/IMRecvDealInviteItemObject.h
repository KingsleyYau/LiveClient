
//
//  IMRecvDealInviteItemObject.h
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

@interface IMRecvDealInviteItemObject : NSObject

/**
 * 主播回复观众多人互动邀请信息
 * @inviteId            邀请ID
 * @roomId              直播间ID
 * @anchorId            主播ID
 * @nickName            主播昵称
 * @photoUrl            主播头像
 * @type                邀请回复（IMANCHORREPLYINVITETYPE_AGREE：接受，IMANCHORREPLYINVITETYPE_REJECT：拒绝，IMANCHORREPLYINVITETYPEE_OUTTIME：邀请超时，IMANCHORREPLYINVITETYPE_CANCEL：观众取消邀请）
 */
@property (nonatomic, copy) NSString *_Nonnull inviteId;
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;
@property (nonatomic, copy) NSString *_Nonnull photoUrl;
@property (nonatomic, assign) IMReplyInviteType type;
@end
