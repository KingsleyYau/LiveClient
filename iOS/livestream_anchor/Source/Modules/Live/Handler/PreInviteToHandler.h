//
//  PreInviteToHandler.h
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreRoomInHandler.h"
#import "InstantInviteItem.h"
#import "LiveRoom.h"
#import "LSAnchorRequestManager.h"
#import "LSAnchorImManager.h"

@class PreInviteToHandler;
@protocol PreInviteToHandlerDelegate <NSObject>
@optional

/**
 9.2 接受立即私密邀请回复回调

 @param item 回调对象
 */
- (void)instantInviteReply:(InstantInviteItem *_Nonnull)item;

/**
 9.5 获取指定立即私密邀请信息回调

 @param inviteid 指定立即私密邀请id
 @param item 回调对象
 */
- (void)getInviteInfoWithId:(NSString * _Nonnull)inviteid imInviteIdItem:(ZBImInviteIdItemObject * _Nonnull)item errType:(ZBLCC_ERR_TYPE)errType errmsg:(NSString * _Nonnull)errmsg;

/**
 主播发送立即私密邀请超时
 */
- (void)inviteIsTimeOut;

@end


@interface PreInviteToHandler : PreRoomInHandler


@property (nonatomic, weak) id <PreInviteToHandlerDelegate> _Nullable  inviteDelegate;


typedef void (^InvitedHandler)(BOOL success, ZBLCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull inviteid, NSString * _Nonnull roomid);

typedef void (^CancelInvitedHandler)(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);

// 邀请ID
@property (nonatomic, copy) NSString * _Nonnull inviteid;


/**
 释放代理
 */
- (void)unInit;

/**
 9.1 主播发送立即私密邀请

 @param userid 主播ID
 @param finshHandler 请求回调
 */
- (BOOL)instantInviteWithUserid:(NSString * _Nonnull)userid finshHandler:(InvitedHandler _Nonnull)finshHandler;

/**
 4.8 主播取消立即私密邀请

 @param inviteid 邀请id
 @param finshHandler 请求回调
 */
- (void)cancelInviteWithId:(NSString * _Nonnull)inviteid finshHandler:(CancelInvitedHandler _Nonnull)finshHandler;

@end
