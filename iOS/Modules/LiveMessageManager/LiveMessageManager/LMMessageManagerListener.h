//
//  LMMessageManagerListener.h
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LMHeader.h"
#include "ImClient/IImClientDef.h"

@protocol LMMessageManagerDelegate <NSObject>
@optional

#pragma mark - 私信联系人 listener(http接口的返回)
//- (void)onGetPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg ContactList:(NSArray<LMPrivateMsgContactObject*>* _Nonnull)ContactList;
//
//- (void)onGetFollowPrivateMsgFriendList:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg  followList:(NSArray<LMPrivateMsgContactObject*>* _Nonnull)followList;

// 当私信联系人列表有改变时，会收到这个回调，这时需要调用getLocalPrivateMsgFriendList
- (void)onUpdateFriendListNotice:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;

#pragma mark - 私信消息公共操作
// 私信刷新消息回调
- (void)onRefreshPrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId list:(NSArray<LMMessageItemObject*>* _Nonnull)list reqId:(int)reqId;
// 私信消息更多消息回调
- (void)onGetMorePrivateMsgWithUserId:(BOOL)success errType:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg userId:(NSString* _Nonnull)userId list:(NSArray<LMMessageItemObject*>* _Nonnull)list reqId:(int)reqId;

// 私信更新消息（放在私信消息队列后面）
- (void)onUpdatePrivateMsgWithUserId:(NSString* _Nonnull)userId msgList:(NSArray<LMMessageItemObject*>* _Nonnull)msgList;
//// 设置私信已读回调（一般不处理, 放弃回调）
//- (void)onSetPrivateMsgReaded:(HTTP_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg;
#pragma mark - 私信listener
// 发送和重发的私信消息的成功或失败，改变发送消息的状态
- (void)onSendPrivateMessage:(BOOL)success errType:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errmsg item:(LMMessageItemObject* _Nonnull)item;
// 这个是重发，返回的回调，回调所有本地私信消息（原因是重发的消息可能要删除时间item，android不好处理，就做成重发就重新设置本地消息的排列，所有消息返回过去）
- (void)onRepeatSendPrivateMsgNotice:(NSString* _Nonnull)userId msgList:(NSArray<LMMessageItemObject*>* _Nonnull)msgList;
// 接收接收的私信消息（用在私信联系人列表处，而聊天间使用的是onUpdatePrivateMsgWithUserId）
- (void)onRecvPrivateMessage:(LMMessageItemObject* _Nonnull)item;

@end
