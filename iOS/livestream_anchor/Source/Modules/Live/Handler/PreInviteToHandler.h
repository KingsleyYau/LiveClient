//
//  PreInviteToHandler.h
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantInviteItem.h"
#import "LiveRoom.h"
#import "ZBLSRequestManager.h"
#import "ZBLSImManager.h"

@class PreInviteToHandler;
@protocol PreInviteToHandlerDelegate <NSObject>
@optional

/**
 9.2 接受立即私密邀请回复回调

 @param item 回调对象
 */
- (void)instantInviteReply:(InstantInviteItem *)item;

/**
 9.5 获取指定立即私密邀请信息回调

 @param inviteid 指定立即私密邀请id
 @param item 回调对象
 */
- (void)getInviteInfoWithId:(NSString *)inviteid imInviteIdItem:(ZBImInviteIdItemObject *)item;

/**
 3.2 主播进入指定直播间回调

 @param roomid 房间id
 @param liveRoom 回调对象
 */

/**
 主播发送立即私密邀请超时
 */
- (void)inviteIsTimeOut;

@end


@interface PreInviteToHandler : NSObject


@property (nonatomic, weak) id<PreInviteToHandlerDelegate> inviteDelegate;


typedef void (^InvitedHandler)(BOOL success, ZBLCC_ERR_TYPE errnum, NSString *errmsg, NSString *inviteid, NSString *roomid);

typedef void (^CancelInvitedHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString *errmsg);

typedef void (^RoomInHandler)(BOOL success, ZBLCC_ERR_TYPE errnum, NSString *errmsg, ZBImLiveRoomObject *item);

// 邀请ID
@property (nonatomic, copy) NSString *inviteid;

/**
 9.1 主播发送立即私密邀请

 @param userid 主播ID
 @param finshHandler 请求回调
 */
- (void)instantInviteWithUserid:(NSString *)userid finshHandler:(InvitedHandler)finshHandler;

/**
 4.8 主播取消立即私密邀请

 @param inviteid 邀请id
 @param finshHandler 请求回调
 */
- (void)cancelInviteWithId:(NSString *)inviteid finshHandler:(CancelInvitedHandler)finshHandler;

/**
 3.2 主播进入指定直播间

 @param roomid 直播间id
 @param finshHandler 结束回调
 */
- (void)sendRoomIn:(NSString *)roomid finshHandler:(RoomInHandler)finshHandler;

@end
