//
//  LSLiveChatManagerOC.h
//  LiveChatLibrary
//
//  Created by alex shum on 2018/11/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSLiveChatManagerListener.h"

@interface LSLiveChatManagerOC : NSObject

@property (nonatomic, strong) NSString *versionCode;

#pragma mark - 获取实例
/**
 *  获取实例
 *
 *  @return 实例
 */
+ (instancetype)manager;

#pragma mark - 委托/获取登录状态
/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<LSLiveChatManagerListenerDelegate>)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<LSLiveChatManagerListenerDelegate>)delegate;

/**
 获取原生socket
 
 @return socket
 */
- (int)getNativeSocket;

#pragma mark - 在线状态
///**
// *  创建livechat管理器
// *
// *  @param domain                要livechatClient登录连接的ip（原QN的同步配置中获取）
// *  @param port                  要livechatClient登录连接的端口（原QN的同步配置中获取）
// *  @param webSite               设置livechatHttp的webSite站点（原QN的requestManager获取）
// *  @param appSite               设置livechatHttp的appSite站点（原QN的requestManager获取）
// *  @param chatVoiceHostUrl      设置livechatClient的语音URL（原QN的同步配置中获取）
// *  @param httpUser              设置http的User（test根据是否dome）
// *  @param httpPassword          设置http的密码（5179根据是否dome）
// *  @param versionCode           版本号
// *  @param cachesDirectory       设置写log路径
// *  @param minChat               livechat最低收费
// *
// *  @return 是否成功
// */
//- (BOOL)createLiveChatManager:(NSString *)domain
//                         port:(int)port
//                      webSite:(NSString *)webSite
//                      appSite:(NSString *)appSite
//             chatVoiceHostUrl:(NSString *)chatVoiceHostUrl
//                     httpUser:(NSString *)httpUser
//                 httpPassword:(NSString *)httpPassword
//                  versionCode:(NSString *)versionCode
//              cachesDirectory:(NSString *)cachesDirectory
//                      minChat:(double)minChat;
//
///**
// *  释放livechat管理器
// *
// *
// *  @return
// */
//- (void)releaseLiveChatManager;

/**
 *  登录livechat管理器（登录c里面的livechatClient，liveChatIM登录调用）
 *
 *  @param domain                要livechatClient登录连接的ip（原QN的同步配置中获取）
 *  @param port                  要livechatClient登录连接的端口（原QN的同步配置中获取）
 *  @param webSite               设置livechatHttp的webSite站点（原QN的requestManager获取）
 *  @param appSite               设置livechatHttp的appSite站点（原QN的requestManager获取）
 *  @param chatVoiceHostUrl      设置livechatClient的语音URL（原QN的同步配置中获取）
 *  @param httpUser              设置http的User（test根据是否dome）
 *  @param httpPassword          设置http的密码（5179根据是否dome）
 *  @param versionCode           版本号
 *  @param appId                 app唯一标识（App包名或iOS App ID，详情参考《“App ID”对照表》）
 *  @param cachesDirectory       设置写log路径
 *  @param minChat               livechat最低收费
 *  @param user                用户ID
 *  @param userName            用户Name
 *  @param sid                 登录的token
 *  @param device              设备
 *  @param livechatInvite      livechat邀请权限
 *  @param isLiveChat          livechat权限
 *  @param isSendPhotoPriv     私密照发送权限
 *  @param isLiveChatPriv     livechat总权限
 *  @return 是否成功
 */
- (BOOL)loginUser:(NSString *)domain
             port:(int)port
          webSite:(NSString *)webSite
          appSite:(NSString *)appSite
 chatVoiceHostUrl:(NSString *)chatVoiceHostUrl
         httpUser:(NSString *)httpUser
     httpPassword:(NSString *)httpPassword
      versionCode:(NSString *)versionCode
            appId:(NSString *)appId
  cachesDirectory:(NSString *)cachesDirectory
          minChat:(double)minChat
             user:(NSString *)user
         userName:(NSString *)userName
              sid:(NSString *)sid
           device:(NSString *)device
   livechatInvite:(NSInteger)livechatInvite
       isLivechat:(BOOL)isLiveChat
  isSendPhotoPriv:(BOOL)isSendPhotoPriv
   isLiveChatPriv:(BOOL)isLiveChatPriv
  isSendVoicePriv:(BOOL)isSendVoicePriv;

/**
 *  立即重登录
 */
- (void)relogin;
/**
 *  获取登录状态
 *
 *  @return 是否正在登录（YES：正在登录，否则为未登录状态）
 */
- (BOOL)isLogin;

/**
 *  注销（并释放LiveChatManManager）
 */
- (void)logoutUser:(BOOL)isResetParam;


/**
 *  获取指定用户在线状态
 *
 *  @param userIds 用户ID数组
 *
 *  @return 操作是否成功
 */

- (BOOL)getUserStatus:(NSArray<NSString *> *)userIds;

/**
 *  停止会话
 *
 *  @param userId 用户Id
 *
 *  @return 操作是否成功
 */
- (BOOL)endTalk:(NSString *)userId;
- (BOOL)endTalk:(NSString *)userId isLiveChat:(BOOL)isLiveChat;
/**
 *  停止所有会话
 *
 *  @return 操作是否成功
 */
- (void)endTalkAll;

/**
 *  根据错误码判断是否时余额不足
 *
 *  @return 是否余额不足
 */
- (BOOL)isNoMoneyWithErrCode:(NSString *)errCode;

#pragma mark - 获取用户信息
/**
 *  获取用户信息
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)getUserInfo:(NSString *)userId;

/**
 *  获取多个用户信息
 *
 *  @param userIds 用户ID数组
 *
 *  @return 操作是否成功
 */
- (int)getUsersInfo:(NSArray<NSString *> *)userIds;

/**
 *  获取自己的服务器name
 */

- (NSString *)getMyServer;

#pragma mark - 试聊券
/**
 *  检测是否可使用试聊券
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)checkTryTicket:(NSString *)userId;

#pragma mark - 公共操作
/**
 *  获取指定用户聊天消息数组
 *
 *  @param userId 用户ID
 *
 *  @return 返回用户聊天消息数组
 */
- (NSArray<LSLCLiveChatMsgItemObject *> *)getMsgsWithUser:(NSString *)userId;

/**
 *  获取用户
 *
 *  @param userId 用户ID
 *
 *  @return 用户
 */
- (LSLCLiveChatUserItemObject *)getUserWithId:(NSString *)userId;

/**
 *
 *
 *  @return 返回邀请用户列表
 */
- (NSArray<LSLCLiveChatUserItemObject *> *)getInviteUsers;

/**
 *  获取在聊用户数组
 *
 *  @return 用户数组
 */
- (NSArray<LSLCLiveChatUserItemObject *> *)getChatingUsers;

/**
 * 在聊用户是否在inchat中
 *  @womanId  女士ID
 *
 *  @return 是否inchat
 */
- (BOOL)isChatingUserInChatState:(NSString *)womanId;

/**
 *  获取男士自动邀请用户数组
 *
 *  @return 用户数组
 */
- (NSArray<LSLCLiveChatUserItemObject *> *)getManInviteUsers;

/**
 * 是否处于男士邀请状态
 *  @womanId  女士ID
 *
 *  @return 是否是男士自动邀请
 */
- (BOOL)isInManInvite:(NSString *)womanId;

/**
 * 获取用户第一条邀请聊天记录是否超过1分钟
 *  @womanId  女士ID
 *
 *  @return 是否可以取消
 */
- (BOOL)isInManInviteCanCancel:(NSString *)womanId;

/**
 * 获取用户的私密照和视频的消息
 *  @userId  用户ID
 *
 *  @return 消息列表
 */
- (NSArray<LSLCLiveChatMsgItemObject *> *)getPrivateAndVideoMessageList:(NSString *)userId;

#pragma mark - 普通消息处理（文本/历史聊天消息等）
/**
 *  发送文本消息
 *
 *  @param userId 用户ID
 *  @param text   文本消息内容
 *
 *  @return 消息
 */
- (LSLCLiveChatMsgItemObject *)sendTextMsg:(NSString *)userId text:(NSString *)text;

/**
 *  获取消息处理状态
 *
 *  @param userId 用户ID
 *  @param msgId  消息ID
 *
 *  @return 消息处理状态
 */
- (StatusType)getMsgStatus:(NSString *)userId msgId:(NSInteger)msgId;

/**
 *  插入历史消息记录
 *
 *  @param userId 用户ID
 *  @param msg    消息
 *
 *  @return 消息ID
 */
- (NSInteger)insertHistoryMessage:(NSString *)userId msg:(LSLCLiveChatMsgItemObject *)msg;

/**
 *  删除历史消息记录(一般用于重发消息)
 *
 *  @param userId 用户ID
 *  @param msgId  消息ID
 *
 *  @return 处理结果
 */
- (BOOL)removeHistoryMessage:(NSString *)userId msgId:(NSInteger)msgId;

/**
 *  获取用户最后一条聊天消息
 *
 *  @param userId 用户ID
 *
 *  @return 最后一条聊天消息
 */
- (LSLCLiveChatMsgItemObject *)getLastMsg:(NSString *)userId;

/**
 *  获取对方最后一条聊天消息
 *
 *  @param userId 用户id
 *
 *  @return 对方最后一条聊天消息
 */
- (LSLCLiveChatMsgItemObject *)getTheOtherLastMessage:(NSString *)userId;

/**
 *  发送图片
 *
 *  @param userId    用户Id
 *  @param photoPath 私密照的路径
 *
 *  @return 私密照消息
 */
- (LSLCLiveChatMsgItemObject *)sendPhoto:(NSString *)userId PhotoPath:(NSString *)photoPath;
/**
 *  购买图片
 *
 *  @param userId 用户Id
 *  @param photoId  私密照Id]
 *  @param inviteId  消息邀请Id
 *
 *  @return 处理结果
 */
- (BOOL)photoFee:(NSString *)userId mphotoId:(NSString *)photoId inviteId:(NSString *)inviteId;
/**
 *  根据消息ID获取图片(模糊或清晰)
 *
 *  @param userId   用户Id
 *  @param photoId    私密照Id
 *  @param sizeType 私密照大小类型
 *
 *  @return 处理结果
 */
- (BOOL)getPhoto:(NSString *)userId photoId:(NSString *)photoId sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType sendType:(SendType)sendType;

/**
 *  // 检查私密照片是否已付费
 *
 *  @param userId 用户Id
 *  @param mphotoId  私密照Id
 *
 *  @return 处理结果
 */
- (BOOL)checkPhoto:(NSString *)userId mphotoId:(NSString *)photoId;

#pragma mark - 高级表情消息处理（大高表）
/**
 * 发送高级表情
 *
 * @param userId   用户Id
 * @param emotionId   大高级表情Id
 *
 * @return 高级表情消息
 */
- (LSLCLiveChatMsgItemObject *)sendEmotion:(NSString *)userId emotionId:(NSString *)emotionId;
/**
 * 获取高级表情配置item
 *
 * @return 高级表情配置item
 */
- (LSLCLiveChatEmotionConfigItemObject *)getEmotionConfigItem;
/**
 * 获取高级表情item
 *
 * @param emotionId 高级表情ID
 *
 * @return 高级表情item
 */
- (LSLCLiveChatEmotionItemObject *)getEmotionInfo:(NSString *)emotionId;
/**
 * 手动下载/更新高级表情图片文件(一张图)
 *
 * @param emotionId 高级表情ID
 *
 * @return 处理结果
 */
- (BOOL)getEmotionImage:(NSString *)emotionId;
/**
 * 手动下载/更新高级表情图片文件（一大张图，并且要载剪成多张图）
 *
 * @param emotionId 高级表情ID
 *
 * @return 处理结果
 */
- (BOOL)getEmotionPlayImage:(NSString *)emotionId;

#pragma mark - 小高级表情消息处理
/**
 * 发送小高级表情
 *
 * @param userId   用户Id
 * @param iconId   小高表Id
 *
 * @return 小高表情配置消息
 */
- (LSLCLiveChatMsgItemObject *)sendMagicIcon:(NSString *)userId iconId:(NSString *)iconId;
/**
 * 获取小高级表情配置item
 *
 * @return 小高表情消息
 */
- (LSLCLiveChatMagicIconConfigItemObject *)getMagicIconConfigItem;
/**
 * 获取小高级表情item
 *
 * @param magicIconId   小高级表情Id
 *
 * @return 小高表情消息
 */
- (LSLCLiveChatMagicIconItemObject *)getMagicIconInfo:(NSString *)magicIconId;
/**
 * 手动下载／更新小高级表情原图source
 *
 * @param magicIconId   小高级表情Id
 *
 * @return
 */
- (BOOL)getMagicIconSrcImage:(NSString *)magicIconId;
/**
 * 手动下载／更新小高级表情拇子图thumb
 *
 * @param magicIconId   小高级表情Id
 *
 * @return
 */
- (BOOL)getMagicIconThumbImage:(NSString *)magicIconId;
/**
 * 获取小高级表情图的路径
 *
 * @param magicIconId   小高级表情Id
 *
 * @return 小高级表情图的路径
 */
-(NSString *)getMagicIconThumbPath:(NSString *)magicIconId;

#pragma mark - Camshare消息处理
/**
 * 发送Camshare邀请
 *
 * @param userId   用户Id
 *
 * @return 成功失败
 */
- (BOOL)sendCamShareInvite:(NSString *)userId;

/**
 * 接受Camshare邀请
 *
 * @param userId   用户Id
 *
 * @return 成功失败
 */
- (BOOL)acceptLadyCamshareInvite:(NSString *)userId;
/**
 * 获取女士Camshare女士状态
 *
 * @param userId   用户Id
 *
 * @return 成功失败
 */
- (BOOL)getLadyCamStatus:(NSString *)userId;

/**
 *  检测Camshare试聊券是否可使用
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)checkCamCoupon:(NSString *)userId;

/**
 *  更新收到视频流时间
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)updateRecvVideo:(NSString *)userId;

/**
 *  检测是否Camshare会话中
 *
 *  @param userId 用户ID
 *
 *  @return 是否
 */
- (BOOL)isCamshareInChat:(NSString *)userId;


/**
 *  检查用户最后一条消息是否是Camshare邀请
 *
 *  @param userId 用户ID
 *
 *  @return 是否
 */
- (BOOL)isCamshareInviteMsg:(NSString *)userId;

/**
 *  检测是否Camshare邀请消息
 *
 *  @param userId 用户ID
 *
 *  @return 是否
 */
- (BOOL)isCamShareInvite:(NSString *)userId;
/**
 *  检测是否需要上传视频
 *
 *  @return 是否
 */
- (BOOL)isUploadVideo;

/**
 *  设置Camshare前后台
 *
 *  @param userId 用户ID
 *
 *  @return 操作是否成功
 */
- (BOOL)setCamShareBackground:(NSString *)userId background:(BOOL)background;

/**
 *  设置Camshare会话心跳超时时间步长
 *
 *  @param timeStep 时间步长
 *
 *  @return 操作是否成功
 */
- (BOOL)setCheckCamShareHeartBeatTimeStep:(int)timeStep;

#pragma mark - 语音消息处理
/**
 * 发送语音
 *
 * @param userId       要发送给的用户ID
 * @param voicePath    语音的文件路径
 * @param fileType     语音文件的类型
 * @param timeLength   语音文件的时间长度（单位秒）
 * @return 语音消息
 */
-(LSLCLiveChatMsgItemObject *)sendVoice:(NSString *)userId voicePath:(NSString *)voicePath fileType:(NSString *)fileType timeLength:(int)timeLength;

/**
 * 获取语音
 *
 * @param userId       用户ID
 * @param msgId        消息Id
 * @return 操作是否成功
 */
-(BOOL)getVoice:(NSString *)userId msgId:(int)msgId;

#pragma mark - 视频消息处理
/**
 * 获取微视频图片
 *
 * @param userId       用户ID
 * @param videoId      视频ID
 * @param inviteId     消息邀请ID
 * @return 操作是否成功
 */
-(BOOL)getVideoPhoto:(NSString* _Nonnull)userId videoId:(NSString* _Nonnull)videoId inviteId:(NSString* _Nonnull)inviteId;
/**
 * 购买微视频
 *
 * @param userId       用户ID
 * @param videoId      视频ID
 * @param inviteId     消息邀请ID
 * @return 操作是否成功
 */
-(BOOL)videoFee:(NSString* _Nonnull)userId videoId:(NSString* _Nonnull)videoId inviteId:(NSString* _Nonnull)inviteId;
/**
 * 获取微视频播放文件
 *
 * @param userId       用户ID
 * @param videoId      视频ID
 * @param inviteId     消息邀请ID
 * @param videoUrl     视频Url
 * @param msgId        消息ID
 * @return 操作是否成功
 */
-(BOOL)getVideo:(NSString* _Nonnull)userId videoId:(NSString* _Nonnull)videoId inviteId:(NSString* _Nonnull)inviteId videoUrl:(NSString* _Nonnull)videoUrl msgId:(int)msgId;
/**
 * 获取视频当前下载状态
 *
 * @param videoId      视频ID
 * @return 操作是否成功
 */
-(BOOL)isGetingVideo:(NSString* _Nonnull)videoId;
/**
 * 获取视频图片文件路径（仅文件存在）
 *
 * @param userId       用户ID
 * @param inviteId     消息邀请ID
 * @param videoId      视频ID
 * @param type         (VPT_DEFAULT:默认尺寸 VPT_BIG:大图)
 * @return
 */
-(NSString* _Nonnull)getVideoPhotoPathWithExist:(NSString* _Nonnull)userId inviteId:(NSString* _Nonnull)inviteId videoId:(NSString* _Nonnull)videoId type:(VIDEO_PHOTO_TYPE)type;
/**
 * 获取视频文件路径（仅文件存在）
 *
 * @param userId       用户ID
 * @param inviteId     消息邀请ID
 * @param videoId      视频ID
 * @return
 */
-(NSString* _Nonnull)getVideoPathWithExist:(NSString* _Nonnull)userId inviteId:(NSString* _Nonnull)inviteId videoId:(NSString* _Nonnull)videoId;

@end
