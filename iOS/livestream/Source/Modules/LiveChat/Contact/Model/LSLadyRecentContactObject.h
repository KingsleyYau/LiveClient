//
//  LSLadyRecentContactObject.h
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLCLiveChatUserItemObject.h"
#import "LSLCLiveChatUserInfoItemObject.h"
#import "LSLCLiveChatMsgItemObject.h"

@interface LSLadyRecentContactObject : NSObject

/** 女士id */
@property (nonatomic, strong) NSString *womanId;
/** 名称 */
@property (nonatomic, strong) NSString *firstname;
/** 年龄 */
@property (nonatomic, assign) NSInteger age;
/** 图片地址 */
@property (nonatomic, strong) NSString *photoURL;
/** 大图地址 */
@property (nonatomic, strong) NSString *photoBigURL;
/** 是否收藏 */
@property (nonatomic, assign) BOOL isFavorite;
/** 视频数 */
@property (nonatomic, assign) NSInteger videoCount;
/** 最后一次联系时间 */
@property (nonatomic, assign) NSInteger lasttime;
/** 在线状态 */
@property (nonatomic, assign) BOOL isOnline;
/** 在聊状态 */
@property (nonatomic, assign) BOOL isInChat;
/** 最后邀请文字 */
@property (nonatomic, strong) NSAttributedString *lastInviteMessage;
/** 视频状态 */
@property (nonatomic, assign) BOOL isInCamshare;
/** 是否有camshare和camshare邀请标识 */
@property (nonatomic, assign) BOOL isCamshareEnable;
/** 是否CamShare邀请信息*/
@property (nonatomic, assign) BOOL isCamShareInviteMsg;

/** 是否男士最后发送的消息 */
@property (nonatomic, assign) BOOL manLastMsg;

/** 未读消息条数 */
@property (nonatomic, assign) NSInteger unreadCount;

/** 用来记录是否在展开编辑状态中 */
@property (nonatomic, assign, getter=isShowBtn) BOOL showBtn;

#pragma mark - 逻辑和界面使用属性和方法
/**
 界面显示的时间
 */
@property (strong, readonly, nonatomic) NSString *userName;

/**
 更新联系人最后联系时间
 */
- (void)updateLastTime;

/**
 更新联系人姓名和头像
 
 @param name 姓名
 @param photoUrl 头像
 */
- (void)updateRecent:(NSString *)name recentPhoto:(NSString *)photoUrl;

/**
 根据LiveChat接口更新用户状态信息
 
 @param userInfo 用户状态信息
 @return 状态是否改变
 */
- (BOOL)updateRecentWithUserItem:(LSLCLiveChatUserItemObject *)userInfo;

/**
 根据LiveChat接口更新用户信息
 
 @param userInfo 用户状态信息
 @return 状态是否改变
 */
- (BOOL)updateRecentWithUserInfoItem:(LSLCLiveChatUserInfoItemObject *)userInfo;

/**
 根据LiveChat消息更新邀请未读
 
 @param msg LiveChat消息
 @return 状态是否改变
 */
- (BOOL)updateInviteNewMsgWithMsg:(LSLCLiveChatMsgItemObject *)msg;

/**
 根据LiveChat消息更新未读
 
 @param msg LiveChat消息
 @return 状态是否改变
 */
- (BOOL)updateRecentNewMsgWithMsg:(LSLCLiveChatMsgItemObject *)msg;

/**
 根据LiveChat消息更新用户信息
 
 @param msg LiveChat消息
 @return 状态是否改变
 */
- (BOOL)updateRecentWithMsg:(LSLCLiveChatMsgItemObject *)msg;

/**
 根据LiveChat消息更新邀请信息
 
 @param msg LiveChat消息
 @return 状态是否改变
 */
- (BOOL)updateInviteWithMsg:(LSLCLiveChatMsgItemObject *)msg;

@end
