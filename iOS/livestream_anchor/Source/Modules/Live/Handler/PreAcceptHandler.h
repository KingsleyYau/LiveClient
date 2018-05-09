//
//  PreAcceptHandler.h
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreRoomInHandler.h"
#import "LSAnchorRequestManager.h"
#import "LSAnchorImManager.h"

@interface PreAcceptHandler : PreRoomInHandler

typedef void (^AcceptInvitedHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, ZBHttpRoomType roomType);

/**
 4.2 主播接收立即私密邀请

 @param inviteid 邀请id
 @param finshHandler 请求回调
 */
- (void)acceptInviteWithId:(NSString * _Nonnull)inviteid finshHandler:(AcceptInvitedHandler _Nonnull)finshHandler;

@end
