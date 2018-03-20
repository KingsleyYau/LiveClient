//
//  PreAcceptHandler.h
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBLSRequestManager.h"
#import "ZBLSImManager.h"

@interface PreAcceptHandler : NSObject

typedef void (^AcceptInvitedHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

typedef void (^RoomInHandler)(BOOL success, ZBLCC_ERR_TYPE errnum, NSString *errmsg, ZBImLiveRoomObject *item);

/**
 3.2 主播进入指定直播间
 
 @param roomid 直播间id
 @param finshHandler 结束回调
 */
- (void)sendRoomIn:(NSString *)roomid finshHandler:(RoomInHandler)finshHandler;

/**
 4.2 主播接收立即私密邀请

 @param inviteid 邀请id
 @param finshHandler 请求回调
 */
- (void)acceptInviteWithId:(NSString *)inviteid finshHandler:(AcceptInvitedHandler)finshHandler;

@end
