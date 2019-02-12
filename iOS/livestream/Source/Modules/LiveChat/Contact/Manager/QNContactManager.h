//
//  ContactManager.h
//  dating
//
//  Created by lance on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLadyRecentContactObject.h"

@class QNContactManager;
@protocol QNContactManagerDelegate <NSObject>
@optional

/**
 *  获取联系人列表回调
 *
 *  @param manager    联系人管理器
 *  @param success    获取是否成功
 *  @param items 最近联系人的列表
 *  @param errmsg     错误信息提示
 */
- (void)manager:(QNContactManager *)manager onSyncRecentContactList:(LSLIVECHAT_LCC_ERR_TYPE)success items:(NSArray *)items  errmsg:(NSString *)errmsg;
/**
 *  联系人状态改变
 *
 *  @param manager          联系人管理器

 */
- (void)onChangeRecentContactStatus:(QNContactManager *)manager;

/**
 收到邀请回调
 
 @param manager 联系人管理器
 */
- (void)onChangeInviteList:(QNContactManager *)manager;

@end
typedef enum {
    ContactManagerStatusNone = 0,     // 未同步过联系人
    ContactManagerStatuSynchornizing, // 正在同步联系人
    ContactManagerStatusSynchornized, // 已经同步过联系人
} ContactManagerStatus;

@interface QNContactManager : NSObject

/**
 联系人管理器状态
 */
@property (assign, readonly) ContactManagerStatus status;

/**
 当前本地的联系人列表
 */
@property (strong, readonly) NSArray<LSLadyRecentContactObject *> *recentItems;

/**
 当前本地的邀请列表
 */
@property (strong, readonly) NSArray<LSLadyRecentContactObject *> *inviteItems;

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)manager;

#pragma mark - 监听者
/**
 *  增加监听者
 *
 *  @param delegate 监听者
 */
- (void)addDelegate:(id<QNContactManagerDelegate>)delegate;

/**
 *  删除监听者
 *
 *  @param delegate 监听者
 */
- (void)removeDelegate:(id<QNContactManagerDelegate>)delegate;

#pragma mark - 本地管理联系人
/**
 *  获取或添加联系人(若不存在则新建联系人object)
 *
 *  @param womanId 女士Id
 *
 *  @return 联系人object
 */
- (LSLadyRecentContactObject *)getOrNewRecentWithId:(NSString *)womanId;


#pragma mark - 同步联系人状态
/**
 *  更新联系人列表
 */
- (void)updateRecents;

/**
 *  判断是否再聊用户
 *
 *  @return 是/否
 */
- (BOOL)isInChatUser:(NSString *)userId;

/**
 更新用户在聊状态
 */
- (void)updateChatingStatus;

/**
 更新女士已读信息
 
 @param womanId 女士Id
 */
- (void)updateReadMsg:(NSString *)womanId;

/**
获取未读总数
 
 @return 未读总数
 */
- (NSInteger)getChatListUnreadCount;


/**
 清空女士聊天列表最后一条消息
 
 @param womanId 女士Id
 */
- (void)removeChatLastMsg:(NSString *)womanId;


@end
