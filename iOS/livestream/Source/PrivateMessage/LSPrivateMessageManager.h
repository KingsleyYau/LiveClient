//
//               .h
//  livestream
//
//  Created by Max on 2018/8/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LMManagerOC.h"
#import "LMHeader.h"


#define INVALID_REQUEST_ID -1


@interface LSPrivateMessageManager : NSObject
@property (strong) LMManagerOC *_Nullable client;

#pragma mark - 获取实例
+ (instancetype _Nonnull)manager;

// 设置LM管理器的信息（包括用户id和同步配置返回值的私信消息）， 一般在http登录成功调用
- (BOOL)setManagerInfo:(NSString* _Nullable)userId privateNotice:(NSString* _Nullable)privateNotice;


#pragma mark - 私信联系人列表
typedef void (^LocalPrivateMsgFriendListHandler)(NSArray<LMPrivateMsgContactObject*>* _Nullable list);
/**
 *  @param finishHandler 获取本地私信联系人列表（同步返回， 当接收到onUpdateFriendListNotice回调时（success为YES），就调用getLocalPrivateMsgFriendList
 *
 */
- (void)getLocalPrivateMsgFriendList:(LocalPrivateMsgFriendListHandler _Nullable)finishHandler;

/**
 *  获取本地私信联系人列表（异步返回, 需要请求返回onUpdateFriendListNotice， 之后用getLocalPrivateMsgFriendList获取私信联系人列表）
 *
 *  @return    操作是否成功
 */
- (BOOL)getPrivateMsgFriendList;

/**
 *  设置私信在聊用户（进入聊天间使用，为了登录重连后根据在聊用户获取最新私信消息）
 *  @param     userId        要聊天的用户
 *  @return    操作是否成功
 */
- (BOOL)addPrivateMsgLiveChat:(NSString* _Nonnull)userId;

/**
 *  移除私信在聊用户
 *  @param     userId        要聊天的用户
 *  @return    操作是否成功
 */
- (BOOL)removePrivateMsgLiveChat:(NSString* _Nonnull)userId;

#pragma mark - 私信消息
typedef void (^LocalPrivateMsgWithUserIdHandler)(NSArray<LMMessageItemObject*>* _Nullable list);
/**
 *  获取指定用户Id的用户的本地消息(直接返回本地消息列表（深拷贝？防止消息被修改）， 不需要向服务器请求的)
 *
 *  @param      userId  对方的用户ID
 *  @param      finishHandler     返回与该用户的私信本地所有消息（一般用在刚进入聊天间使用）
 */
- (void)getLocalPrivateMsgWithUserId:(NSString* _Nonnull)userId finishHandler:(LocalPrivateMsgWithUserIdHandler _Nullable)finishHandler;

typedef void (^RefreshPrivateMsgHandler)(BOOL success, HTTP_LCC_ERR_TYPE errType, NSString *_Nonnull errMsg,NSArray<LMMessageItemObject*>* _Nonnull list);
/**
 *  获取指定用户Id的用户的私信消息（不能直接返回的，需要考虑刷新消息标记,都是异步返回的。一般用于刚进私信间和重连后调用GetLocalPrivateMsgWithUserId后再使用这个）
 *
 *  @param  userId          对方的用户ID
 *  @param  finishHandler   回调
 *  @return     操作是否成功
 */
- (BOOL)refreshPrivateMsgWithUserId:(NSString* _Nonnull)userId finishHandler:(RefreshPrivateMsgHandler _Nullable)finishHandler;

/**
 *  获取指定用户Id的用户更多私信消息（不能直接返回的，需要考虑刷新消息标记和是否有本地数据）
 *
 *  @param  userId  对方的用户ID
 *  @return     操作是否成功
 */
- (BOOL)getMorePrivateMsgWithUserId:(NSString* _Nonnull)userId;

/**
 *  设置已读私信消息（在聊天间时，有返回私信消息时调用，如refreshPrivateMsgWithUserId的回调后调用，还有onUpdatePrivateMsgWithUserId有私信消息更新也要调用）
 *
 *  @param  userId  对方的用户ID
 *  @return     操作是否成功
 */
- (BOOL)setPrivateMsgReaded:(NSString* _Nonnull)userId;

// -------- 私信/消息 --------
/**
 *  发送私信消息，返回是要发送的消息（是否成功是看回调，onUpdatePrivateMsgWithUserId回调过来，需要看item的消息处理状态）
 *
 *  @param  userId  对方的用户ID
 *  @param  message 私信内容
 *  @return         返回发送私信的一条直播消息item
 */
- (BOOL)sendPrivateMessage:(NSString* _Nonnull)userId message:(NSString* _Nonnull)message;
/**
 *  重发送私信消息，返回是要发送的消息（是否成功是看回调，onUpdatePrivateMsgWithUserId回调过来，需要看item的消息处理状态）
 *
 *  @param  userId  对方的用户ID
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
