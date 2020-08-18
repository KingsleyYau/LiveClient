//
//  LiveUrlHandler.h
//  livestream
//
//  Created by test on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSUrlParmItem.h"
#import "LiveRoom.h"

@class LiveUrlHandler;
/**
 URL跳转解析回调
 */
@protocol LiveUrlHandlerParseDelegate <NSObject>
#pragma mark - 主界面回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler openMainType:(LiveUrlMainListType)type;
#pragma mark - 个人详情回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler openAnchorDetail:(NSString *)anchorId;
#pragma mark - 直播间回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler openPreLive:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType;
- (void)liveUrlHandler:(LiveUrlHandler *)handler openPrivateLive:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType;
#pragma mark - 节目直播间回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler openShow:(NSString *)showId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType;
#pragma mark - 多人互动直播间回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler openHangout:(NSString *)roomId inviteAnchorId:(NSString *)inviteAnchorId inviteAnchorName:(NSString *)inviteAnchorName recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName;

- (void)liveUrlHandler:(LiveUrlHandler *)handler openInvited:(NSString *)anchorName anchorId:(NSString *)anchorId inviteId:(NSString *)inviteId;
#pragma mark - 预约回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler openBooking:(NSString *)anchorId anchorName:(NSString *)anchorName;
- (void)liveUrlHandler:(LiveUrlHandler *)handler openBookingList:(LiveUrlBookingListType)bookListType;
#pragma mark - 背包回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler openBackpackList:(LiveUrlBackpackListType)backpackListType;
#pragma mark - 买点回调
- (void)liveUrlHandlerOpenAddCredit:(LiveUrlHandler *)handler;
#pragma mark - 个人中心回调
- (void)liveUrlHandlerOpenMyLevel:(LiveUrlHandler *)handler;
#pragma mark - 私信回调
- (void)liveUrlHandlerOpenChatList:(LiveUrlHandler *)handler;
- (void)liveUrlHandler:(LiveUrlHandler *)handler openChatWithAnchor:(NSString *)anchorId anchorName:(NSString *)anchorName;
#pragma mark - 信件回调
- (void)liveUrlHandlerOpenGreetMailList:(LiveUrlHandler *)handler;
- (void)liveUrlHandlerOpenMailList:(LiveUrlHandler *)handler;
#pragma mark - 对话框回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenYesNoDialogTitle:(NSString *)title msg:(NSString *)msg yesTitle:(NSString *)yesTitle noTitle:(NSString *)noTitle yesUrl:(NSString *)yesUrl;
#pragma mark - 聊天界面回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenLiveChatLady:(NSString *)anchorId anchorName:(NSString *)anchorName inviteMsg:(NSString *)msg;
#pragma mark - 聊天列表界面回调
- (void)liveUrlHandlerOpenLiveChatList:(LiveUrlHandler *)handler;
#pragma mark - 发信界面回调
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenSendMail:(NSString *)anchorId anchorName:(NSString *)anchorName emfId:(NSString *)emfId;
#pragma mark - 多人直播弹窗
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutDialog:(NSString *)anchorId anchorName:(NSString *)anchorName;
#pragma mark - 多人直播
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenHangoutRoom:(NSString *)anchorId anchorName:(NSString *)anchorName;
#pragma mark - sayhi列表
- (void)liveUrlHandler:(LiveUrlHandler *)handler openSayHiType:(LiveUrlSayHiListType)type;
#pragma mark - 发送sayhi
- (void)liveUrlHandler:(LiveUrlHandler *)handler didSendSayhi:(NSString *)anchorId anchorName:(NSString *)anchorName;
#pragma mark - sayhi详情
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenSayHiDetail:(NSString *)sayhiId;

#pragma mark - 意向信详情
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenGreetingMailDetail:(NSString *)loiId;
#pragma mark - 鲜花礼品
- (void)liveUrlHandler:(LiveUrlHandler *)handler openGiftFlowerList:(LiveUrlGiftFlowerListType)type;
- (void)liveUrlHandler:(LiveUrlHandler *)handler openGiftFlowerAnchorStore:(NSString *)anchorId;
#pragma mark - 预约私密
- (void)liveUrlHandler:(LiveUrlHandler *)handler openScheduleList:(LiveUrlScheduleListType)type;
- (void)liveUrlHandler:(LiveUrlHandler *)handler openScheduleDetail:(NSString *)inviteId refId:(NSString *)refId anchorId:(NSString *)anchorId;
- (void)liveUrlHandler:(LiveUrlHandler *)handler openScheduleMailDetail:(NSString *)loid anchorName:(NSString *)anchorName type:(LiveUrlScheduleMailDetailType)type;
- (void)liveUrlHandler:(LiveUrlHandler *)handler openSendScheduleMail:(NSString *)anchorId;
#pragma mark - 付费视频
- (void)liveUrlHandlerOpenPremiumVideoList:(LiveUrlHandler *)handler;
- (void)liveUrlHandler:(LiveUrlHandler *)handler didOpenPremiumVideoDetail:(NSString *)videoId andAnchor:(NSString *)anchorId;

@end

/**
 URL跳转处理回调
 */
@protocol LiveUrlHandlerDelegate <NSObject>
@optional
/**
 更新打开模块的URL
 
 @param handler 链接管理器
 */
- (void)handlerUpdateUrl:(LiveUrlHandler *)handler;
@end

@interface LiveUrlHandler : NSObject
/**
 URL链接更新委托
 */
@property (weak) id<LiveUrlHandlerDelegate> delegate;

/**
 URL解析委托
 */
@property (weak) id<LiveUrlHandlerParseDelegate> parseDelegate;

/**
 获取实例

 @return 实例
 */
+ (instancetype)shareInstance;

/**
 解析调用过来的URL
 
 @param url 原始链接
 
 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 触发打开URL的处理
 */
- (void)openURL;

/**
 获取对URL的解析

 @param url 原始链接
 @return 解析的结构体
 */
- (LSUrlParmItem *)parseUrlParms:(NSURL *)url;

#pragma mark - 生成模块的URL
/**
 生成跳转HangOut直播间URL

 @param roomId 直播间Id
 @param inviteAnchorId 邀请主播Id
 @param inviteAnchorName 邀请主播名称
 @param recommendAnchorId 推荐主播id
 @param recommendAnchorName 推荐主播名称
 @return URL
 */
- (NSURL *)createUrlToHangoutByRoomId:(NSString *)roomId inviteAnchorId:(NSString *)inviteAnchorId inviteAnchorName:(NSString *)inviteAnchorName recommendAnchorId:(NSString *)recommendAnchorId recommendAnchorName:(NSString *)recommendAnchorName;

/**
 生成跳转主动邀请URL

 @param roomId 直播间Id
 @param anchorId 主播Id
 @param anchorName 主播名称
 @param roomType 直播间类型
 @return URL
 */
- (NSURL *)createUrlToInviteByRoomId:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId roomType:(LiveRoomType)roomType;

/**
 生成跳转节目URL

 @param roomId 直播间Id
 @param anchorId 主播Id
 @param anchorName 主播名称
 @return URL
 */
- (NSURL *)createUrlToShowRoomId:(NSString *)roomId anchorName:(NSString *)anchorName anchorId:(NSString *)anchorId;

/**
 生成跳转应邀URL

 @param inviteId 邀请Id
 @param anchorId 主播Id
 @param anchorName 主播名称
 @return URL
 */
- (NSURL *)createUrlToInviteByInviteId:(NSString *)inviteId anchorId:(NSString *)anchorId anchorName:(NSString *)anchorName;

/**
 生成跳转女士详情URL

 @param anchorId 主播Id
 @return URL
 */
- (NSURL *)createUrlToAnchorDetail:(NSString *)anchorId;

/**
 生成跳转主页URL

 @param type 分栏类型
 @return URL
 */
- (NSURL *)createUrlToHomePage:(LiveUrlMainListType)type;

/**
 生成发信URL
 
 @param anchorId 主播Id
 @param anchorName 主播名称
 @param emfId 信件id
 @return URL
 */
- (NSURL *)createSendmailByanchorId:(NSString *)anchorId anchorName:(NSString *)anchorName emfiId:(NSString *)emfId;

/**
 生成liveChat聊天室URL
 
 @param anchorId 主播Id
 @param anchorName 主播名称
 @return URL
 */
- (NSURL *)createLiveChatByanchorId:(NSString *)anchorId anchorName:(NSString *)anchorName;

/**
 生成SayHi列表URL

 @param type 列表类型
 @return URL
 */
- (NSURL *)createOpenSayHiList:(LiveUrlSayHiListType)type;

/**
 生成编辑SayHi界面URL

 @param anchorId 主播ID
 @param anchorName 主播名称
 @return URL
 */
- (NSURL *)createSendSayhiByAnchorId:(NSString *)anchorId anchorName:(NSString *)anchorName;

/**
 生成SayHi详情URL

 @param sayhiId SayHiId
 @return URL
 */
- (NSURL *)createSayHiDetailBySayhiId:(NSString *)sayhiId;

/// 生成指定的鲜花礼品商城
/// @param anchorId 主播id
- (NSURL *)createFlowerGightByAnchorId:(NSString *)anchorId;

/// 生成鲜花礼品列表
- (NSURL *)createFlowerStore:(LiveUrlGiftFlowerListType)type;

///  生成预约列表
/// @param type 预约列表类型
- (NSURL *)createScheduleList:(LiveUrlScheduleListType)type;

///  生成信件预约详情页
/// @param mailId 信件id
/// @param anchorName 主播名称
/// @param type 信件类型
- (NSURL *)createScheduleMailDetail:(NSString *)mailId anchorName:(NSString *)anchorName type:(LiveUrlScheduleMailDetailType)type;

/// 生成预约详情
/// @param inviteId 邀请id
/// @param anchorId 主播id
/// @param refId 关联id
- (NSURL *)createScheduleDetail:(NSString *)inviteId anchorId:(NSString *)anchorId refId:(NSString *)refId;
// 生成买点链接
- (NSURL *)createBuyCredit;

/// 生成发送预付费邮件
/// @param anchorId 主播id
- (NSURL *)createUrlToSendScheduleMail:(NSString *)anchorId;

// 付费视频列表
- (NSURL *)createPrmiumVideoList;

// 付费视频详情
- (NSURL *)createPrmiumVideoDetail:(NSString *)videoId andAnchor:(NSString *)anchorId;
@end
