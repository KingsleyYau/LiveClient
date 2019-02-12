
//
//  ImInviteErrItemObject.h
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImAuthorityItemObject.h"
#include "IImClientDef.h"

/**
  邀请错误信息Object
 */
@interface ImInviteErrItemObject : NSObject

/**
 * 邀请错误信息
 *  @chatOnlineStatus  Chat在线状态（IMCHATONLINESTATUS_OFF：离线，IMCHATONLINESTATUS_ONLINE：在线）
 *  @priv         权限
 */
@property (nonatomic, assign) IMChatOnlineStatus status;
@property (nonatomic, strong) ImAuthorityItemObject* priv;

@end
