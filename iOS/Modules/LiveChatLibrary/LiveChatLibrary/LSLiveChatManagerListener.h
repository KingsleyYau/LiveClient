//
//  LSLiveChatManagerListener.h
//  dating
//
//  Created by  Alex on 2018/11/9.
//  Copyright © 2018 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <manrequesthandler/LSLiveChatRequestLiveChatDefine.h>

#import "LSLCLiveChatUserItemObject.h"
#import "LSLCLiveChatMsgItemObject.h"
#import "LSLCLiveChatUserInfoItemObject.h"
#import "LSLCLiveChatMsgPhotoItem.h"
#import "LSLCLiveChatEmotionItemObject.h"
#import "LSLCLiveChatEmotionConfigItemObject.h"
#import "LSLCLiveChatMagicIconItemObject.h"
#import "LSLCLiveChatMagicIconConfigItemObject.h"
#import "LSLCLiveChatScheduleInfoItemObject.h"

@protocol LSLiveChatManagerListenerDelegate <NSObject>
@optional

#pragma mark - 登录/注销回调
/**
 *  登录回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param isAutoLogin 是否将自动登录
 */
- (void)onLogin:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg isAutoLogin:(BOOL)isAutoLogin;

/**
 *  注销回调
 *
 *  @param errType     结果类型
 *  @param errmsg      结果描述
 *  @param isAutoLogin 是否将自动登录
 */
- (void)onLogout:(LSLIVECHAT_LCC_ERR_TYPE)errType errmsg:(NSString *_Nonnull)errmsg isAutoLogin:(BOOL)isAutoLogin;

#pragma mark - 在线状态回调
/**
 *  接收被踢下线通知回调
 *
 *  @param kickType 被踢下线类型
 */
- (void)onRecvKickOffline:(KICK_OFFLINE_TYPE)kickType;

/**
 *  在线状态改变通知回调
 *
 *  @param user 用户
 */
- (void)onChangeOnlineStatus:(LSLCLiveChatUserItemObject *_Nonnull)user;

/**
 *  获取指定用户在线状态回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户list
 */
- (void)onGetUserStatus:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg users:(NSArray<LSLCLiveChatUserItemObject *> *_Nonnull)users;

#pragma mark - 获取用户信息
/**
 *  获取用户信息回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userId   用户ID
 *  @param userInfo 用户信息
 */
- (void)onGetUserInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg userId:(NSString *_Nonnull)userId userInfo:(LSLCLiveChatUserInfoItemObject *_Nullable)userInfo;

/**
 *  获取多个用户信息回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户信息数组
 */
- (void)onGetUsersInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg seq:(int)seq userIdList:(NSArray *_Nonnull)userIdList usersInfo:(NSArray<LSLCLiveChatUserInfoItemObject *> *_Nonnull)usersInfo;

/**
 *  登录后的联系人回调
 *
 *  @param errType  结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户信息数组
 */
- (void)onGetContactList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg usersInfo:(NSArray<LSLCLiveChatUserInfoItemObject *> *_Nonnull)usersInfo;
#pragma mark - 聊天状态回调
/**
 *  获取在聊列表回调
 *
 *  @param errType 结果类型
 *  @param errMsg  结果描述
 */
- (void)onGetTalkList:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg;

/**
 *  接收聊天会话结束
 *
 *  @param user 用户
 */
- (void)onEndTalk:(LSLCLiveChatUserItemObject *_Nonnull)user;

/**
 *  接收聊天状态改变通知回调
 *
 *  @param user 用户
 */
- (void)onRecvTalkEvent:(LSLCLiveChatUserItemObject *_Nonnull)user;

#pragma mark - notice
/**
 *  接收Admirer/EMF通知回调
 *
 *  @param userId     用户ID
 *  @param noticeType 通知类型
 */
- (void)onRecvEMFNotice:(NSString *_Nonnull)userId noticeType:(TALK_EMF_NOTICE_TYPE)noticeType;

#pragma mark - 试聊券回调
/**
 *  检测是否可使用试聊券回调
 *
 *  @param success 检测操作成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param userId  用户ID
 *  @param status  检测结果
 */
- (void)onCheckTryTicket:(BOOL)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg userId:(NSString *_Nonnull)userId status:(CouponStatus)status;

/**
 *  使用试聊券回调
 *
 *  @param errType   结果类型
 *  @param errMsg    结果描述
 *  @param userId    用户ID
 *  @param tickEvent 试聊事件
 */
- (void)onUseTryTicket:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg userId:(NSString *_Nonnull)userId tickEvent:(TRY_TICKET_EVENT)tickEvent;

/**
 *  开始试聊回调
 *
 *  @param user 用户
 *  @param time 试聊时长（秒）
 */
- (void)onRecvTryTalkBegin:(LSLCLiveChatUserItemObject *_Nullable)user time:(NSInteger)time;

/**
 *  结束试聊回调
 *
 *  @param user 用户
 */
- (void)onRecvTryTalkEnd:(LSLCLiveChatUserItemObject *_Nullable)user;

#pragma mark - 普通消息处理回调（包括文本/系统/警告消息）
/**
 *  发送文本消息回调
 *
 *  @param errType 结果类型
 *  @param errMsg  结果描述
 *  @param msg 消息
 */
- (void)onSendTextMsg:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject *_Nullable)msg;

/**
 *  发送消息失败回调（多条）
 *
 *  @param errType 结果类型
 *  @param msgs    消息数组
 */
- (void)onSendTextMsgsFail:(LSLIVECHAT_LCC_ERR_TYPE)errType msgs:(NSArray<LSLCLiveChatMsgItemObject *> *_Nonnull)msgs;

/**
 *  接收文本消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvTextMsg:(LSLCLiveChatMsgItemObject *_Nonnull)msg;

/**
 *  接收系统消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvSystemMsg:(LSLCLiveChatMsgItemObject *_Nonnull)msg;

/**
 *  接收警告消息回调
 *
 *  @param msg 消息
 */
- (void)onRecvWarningMsg:(LSLCLiveChatMsgItemObject *_Nonnull)msg;

/**
 *  对方编辑消息回调
 *
 *  @param userId 用户ID
 */
- (void)onRecvEditMsg:(NSString *_Nonnull)userId;

/**
 *  获取单个用户历史聊天记录回调（包括文本、高级表情、语音、图片）
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param userId  用户ID
 */
- (void)onGetHistoryMessage:(BOOL)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg userId:(NSString *_Nonnull)userId;

/**
 *  获取多个用户历史聊天记录回调（包括文本、高级表情、语音、图片）
 *
 *  @param success  操作是否成功
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param userList 用户数组
 */
- (void)onGetUsersHistoryMessage:(BOOL)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg userIds:(NSArray<NSString *> *_Nonnull)userIds;

/**
 *  直播发送预约Schedule邀请（包含发送，接受，拒绝）
 *
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param womanId 女士ID
 *  @param item       预约信息
 *  @param msgReplyItem  预付费回复信息
 */
- (void)onSendScheduleInvite:(LSLIVECHAT_LCC_ERR_TYPE)errNo errMsg:(NSString *_Nonnull)errMsg womanId:(NSString *_Nonnull)womanId item:(LSLCLiveChatMsgItemObject *_Nonnull)item msgReplyItem:(LSLCLiveChatMsgItemObject *_Nullable)msgReplyItem;

/**
 *  直播接收预约Schedule邀请（包含接收，接受，拒绝）
 *
 *  @param item       预约信息
 *  @param womanId 主播ID
 *  @param scheduleReplyItem 预约回复item（NULL 是发送）
 */
- (void)onRecvScheduleInviteNotice:(LSLCLiveChatMsgItemObject *_Nonnull)item womanId:(NSString *_Nonnull)womanId scheduleReplyItem:(LSLCLiveChatMsgItemObject *_Nullable)scheduleReplyItem;

#pragma mark - 私密照回调
/**
 *  获取私密照图片回调
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgList 与该私密照相关的消息列表
 *  @param sizeType 私密照尺寸
 */

- (void)onGetPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg msgList:(NSArray<LSLCLiveChatMsgItemObject *> *_Nonnull)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType;

/**
 *  获取图片
 *
 *  @param msgItem 消息
 */
- (void)onRecvPhoto:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

/**
 *  获取收费的图片
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onPhotoFee:(bool)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

/**
 *  检查收费状态
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onCheckPhotoFeeStatus:(bool)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

/**
 *  发送私密照信息回调
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onSendPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

#pragma mark - 视频回调

- (void)onGetVideo:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:(NSString *_Nonnull)userId videoId:(NSString *_Nonnull)videoId inviteId:(NSString *_Nonnull)inviteId videoPath:(NSString *_Nonnull)videoPath msgList:(NSArray<LSLCLiveChatMsgItemObject *> *_Nonnull)msgList;

- (void)onGetVideoPhoto:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg userId:(NSString *_Nonnull)userId inviteId:(NSString *_Nonnull)inviteId videoId:(NSString *_Nonnull)videoId videoType:(VIDEO_PHOTO_TYPE)videoType videoPath:(NSString *_Nonnull)videoPath msgList:(NSArray<LSLCLiveChatMsgItemObject *> *_Nonnull)msgList;

/**
 *  接收视频消息
 *
 *  @param msgItem 消息Object
 *
 */
- (void)onRecvVideo:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

/**
 *  购买视频信息回调
 *
 *  @param success 操作是否成功
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onVideoFee:(bool)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

#pragma mark - 高级表情回调
/**
 *  获取高级表情设置item
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param config  高级表情设置消息
 */
- (void)onGetEmotionConfig:(bool)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg otherEmtConItem:(LSLCLiveChatEmotionConfigItemObject *_Nullable)config;

/**
 *  手动下载/更新高级表情图片文件
 *
 *  @param success 操作是否成功
 *  @param item    高级表情Object
 */
- (void)onGetEmotionImage:(bool)success emtItem:(LSLCLiveChatEmotionItemObject *_Nullable)item;

/**
 *  手动下载/更新高级表情图片文件
 *
 *  @param succes  操作是否成功
 *  @param item    高级表情Object
 */
- (void)onGetEmotionPlayImage:(bool)success emtItem:(LSLCLiveChatEmotionItemObject *_Nullable)item;

/**
 *  发送高级表情回调
 *
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param msgItem  消息Object
 */
- (void)onSendEmotion:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject *_Nullable)msgItem;

/**
 *  接受高级表情
 *
 *  @param 消息Object
 *
 */
- (void)onRecvEmotion:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

#pragma mark - 小高级表情回调
/**
 *  获取小高级表情设置item
 *
 *  @param success 操作是否成功
 *  @param errNo   结果类型
 *  @param errMsg  结果描述
 *  @param config  小高级表情设置消息
 */
- (void)onGetMagicIconConfig:(bool)success errNo:(NSString *_Nonnull)errNo errMsg:(NSString *_Nonnull)errMsg magicIconConItem:(LSLCLiveChatMagicIconConfigItemObject *_Nonnull)config;

/**
 *  手动下载/更新小高级表情图片文件
 *
 *  @param success 操作是否成功
 *  @param item    小高级表情Object
 */
- (void)onGetMagicIconSrcImage:(bool)success magicIconItem:(LSLCLiveChatMagicIconItemObject *_Nonnull)item;

/**
 *  手动下载/更新小高级表情图片文件
 *
 *  @param succes  操作是否成功
 *  @param item    小高级表情Object
 */
- (void)onGetMagicIconThumbImage:(bool)success magicIconItem:(LSLCLiveChatMagicIconItemObject *_Nonnull)item;

/**
 *  发送小高级表情回调
 *
 *  @param errNo    结果类型
 *  @param errMsg   结果描述
 *  @param msgItem  消息Object
 */
- (void)onSendMagicIcon:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject *_Nullable)msgItem;

/**
 *  接受小高级表情
 *
 *  @param 消息item
 *
 */
- (void)onRecvMagicIcon:(LSLCLiveChatMsgItemObject *_Nonnull)msgItem;

#pragma mark - Camshare回调

/**
 收到女士接受Camshare邀请
 
 @param userId 用户Id
 @param isAccept 是否接受
 */
- (void)onRecvCamAcceptInvite:(NSString *_Nonnull)userId isAccept:(BOOL)isAccept;

/**
 收到Camshare邀请可以拒绝
 
 @param userId 用户Id
 */
- (void)onRecvCamInviteCanCancel:(NSString *_Nonnull)userId;

/**
 收到Camshare服务断开
 
 @param errType 错误码
 @param userId 用户Id
 */
- (void)onRecvCamDisconnect:(LSLIVECHAT_LCC_ERR_TYPE)errType userId:(NSString *_Nonnull)userId;

/**
 收到女士Camshare服务状态改变
 
 @param userId 用户Id
 @param isOpenCam 是否打开Camshare服务
 */
- (void)onRecvLadyCamStatus:(NSString* _Nonnull)userId isOpenCam:(BOOL)isOpenCam;

/**
 收到女士Camshare服务后台超时
 
 @param userId 用户Id
 @param isEnd 是否已经超时并准备结束Camshare服务
 */
- (void)onRecvBackgroundTimeoutTips:(NSString* _Nonnull)userId;

/**
 获取女士Camshare状态回调
 
 @param userId 用户Id
 @param errType 错误码
 @param errmsg 错误提示
 @param isOpenCam 是否打开Camshare服务
 */
- (void)onGetLadyCamStatus:(NSString* _Nonnull)userId errType:(LSLIVECHAT_LCC_ERR_TYPE)errType errmsg:(NSString* _Nonnull)errmsg isOpenCam:(BOOL)isOpenCam;

/**
 检查Camshare试聊券
 
 @param success 成功失败
 @param errNo 错误码
 @param errMsg 错误提示
 @param userId 用户Id
 @param status 试聊券状态
 */
- (void)onCheckCamCoupon:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId status:(CouponStatus)status couponTime:(int)couponTime;

/**
 使用Camshre试聊券
 
 @param errType 错误码
 @param errMsg 错误提示
 @param userId 用户Id
 */
- (void)onUseCamCoupon:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId;

#pragma mark - 语音消息回调
/**
 *  获取语音消息回调回调
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */

- (void)onGetVoice:(LSLIVECHAT_LCC_ERR_TYPE)errType errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg msgItem:(LSLCLiveChatMsgItemObject* _Nonnull)msgItem;

/**
 *  接收到语音消息
 *
 *  @param msgItem 消息
 */
- (void)onRecvVoice:(LSLCLiveChatMsgItemObject* _Nonnull)msgItem;

/**
 *  发送语音消息回调
 *
 *  @param errType 结果类型
 *  @param errNo   结果编码
 *  @param errMsg  结果描述
 *  @param msgItem 消息
 */
- (void)onSendVoice:(LSLIVECHAT_LCC_ERR_TYPE) errType errNo:(NSString* _Nonnull) errNo errMsg:(NSString* _Nonnull) errMsg msgItem:(LSLCLiveChatMsgItemObject* _Nonnull) msgItem;

- (void)onTokenOverTimeHandler:(NSString* _Nonnull)errMsg;

/**
 *  接收发送邀请语回调
 *
 *  @param msg 消息
 */
- (void)onRecvAutoInviteMsg:(LSLCLiveChatMsgItemObject *_Nonnull)msg;

@end
