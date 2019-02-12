//
//  LMManagerOC.h
//
//  Created by  Samson on 25/06/2018.
//  Copyright © 2017 Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LMMessageManagerListener.h"
//#include "ILiveMessageManManager.h"
#include "ILiveMessageDef.h"
#import "LMHandleHttpListener.h"


@interface LMManagerOC : NSObject
#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype _Nonnull)manager;
#pragma mark - 委托
/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<LMMessageManagerDelegate> _Nonnull)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<LMMessageManagerDelegate> _Nonnull)delegate;

/**
 *  设置http请求委托（只在LSPrivateMessageManager调用，其他地方不调用）
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (void)setHttpRequestDelegate:(id<LMHandleHttpListenerDelegate> _Nonnull)delegate;

/**
 *  初始化直播消息管理器
 *  @param  imClient                IMClient的地址（指针转long，和IM中的imClient同一个用于同一个环境收发消息）
 */
- (BOOL)initManager:(long)imClient;

/**
 * 直播消息管理器信息
 */
- (BOOL)setManagerInfo:(NSString* _Nullable)userId privateNotice:(NSString* _Nullable)privateNotice;



// ---------- 私信列表操作 ----------
/**
 *  获取本地私信联系人列表（同步返回）
 *
 *  @return     返回本地私信联系人列表
 */
- (NSArray<LMPrivateMsgContactObject*>* _Nullable)getLocalPrivateMsgFriendList;

/**
 *  获取本地私信联系人列表（异步返回, 需要请求返回）
 *
 *  @return    操作是否成功
 */
- (BOOL)getPrivateMsgFriendList;

/**
 *  获取本地私信Follow联系人列表同步返回）
 *
 *  @return     返回获取本地私信Follow联系人列表
 */
- (NSArray<LMPrivateMsgContactObject*>* _Nullable)getLocalFollowPrivateMsgFriendList;

/**
 *  获取本地私信联系人列表（异步返回, 需要请求返回）
 *
 *  @return     操作是否成功
 */
- (BOOL)getFollowPrivateMsgFriendList;

/**
 *  增加私信在聊列表
 *
 *  @return     操作是否成功
 */
- (BOOL)addPrivateMsgLiveChat:(NSString* _Nonnull)userId;

/**
 *  删除私信在聊列表
 *
 *  @return     操作是否成功
 */
- (BOOL)removePrivateMsgLiveChat:(NSString* _Nonnull)userId;

// ---------- 私信消息公共操作 ----------
/**
 *  获取指定用户Id的用户的本地消息(直接返回本地消息列表（深拷贝？防止消息被修改）， 不需要向服务器请求的)
 *
 *  @param  userId  对方的用户ID
 *  @return     返回获取本地私信Follow联系人列表
 */
- (NSArray<LMMessageItemObject*>* _Nullable)getLocalPrivateMsgWithUserId:(NSString* _Nonnull)userId;

/**
 *  获取指定用户Id的用户的私信消息（不能直接返回的，需要考虑刷新消息标记,都是异步返回的。一般用于刚进私信间和重连后调用GetLocalPrivateMsgWithUserId后再使用这个）
 *
 *  @param  userId  对方的用户ID
 *  @return     请求参数
 */
- (int)refreshPrivateMsgWithUserId:(NSString* _Nonnull)userId;

/**
 *  获取指定用户Id的用户更多私信消息（不能直接返回的，需要考虑刷新消息标记和是否有本地数据）
 *
 *  @param  userId  对方的用户ID
 *  @return     操作是否成功
 */
- (int)getMorePrivateMsgWithUserId:(NSString* _Nonnull)userId;

/**
 *  提交阅读私信（用于私信聊天间，向服务器提交已读私信）
 *
 *  @param  userId  对方的用户ID
 *  @return     操作是否成功
 */
- (BOOL)setPrivateMsgReaded:(NSString* _Nonnull)userId;

// -------- 私信/消息 --------
/**
 *  发送私信消息，返回是要发送的消息（是否成功是看回调）
 *
 *  @param  userId  对方的用户ID
 *  @param  message 私信内容
 *  @return         返回发送私信的一条直播消息item
 */
- (BOOL)sendPrivateMessage:(NSString* _Nonnull)userId message:(NSString* _Nonnull)message;
/**
 *  重新发送私信消息，返回是要发送的消息（是否成功是看回调）
 *
 *  @param  userId  对方的用户ID
 *  @param  sendMsgId 重发私信的msgId
 *  @return         返回发送私信的一条直播消息item
 */
- (BOOL)repeatSendPrivateMsg:(NSString* _Nonnull)userId sendMsgId:(int)sendMsgId;

/**
 *  该用户是否还有更多私信消息
 *
 *  @param  userId  对方的用户ID
 *  @return  是否可以下拉更多
 */
- (BOOL)isHasMorePrivateMsgWithUserId:(NSString* _Nonnull)userId;

@end
