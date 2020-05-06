//
//  LSLCLiveChatItem2OCObj.h
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILSLiveChatManManager.h>
#import "LSLCLiveChatUserItemObject.h"
#import "LSLCLiveChatMsgItemObject.h"
#import "LSLCLiveChatUserInfoItemObject.h"
#import "LSLCLiveChatMsgPhotoItem.h"
#import "LSLCLiveChatEmotionItemObject.h"
#import "LSLCLiveChatEmotionConfigItemObject.h"
#import "LSLCLiveChatMagicIconItemObject.h"
#import "LSLCLiveChatMagicIconConfigItemObject.h"
#import "LSLCLiveChatMsgVoiceItem.h"
#import "LSLCLiveChatMsgVideoItem.h"
#import "LSLCLiveChatScheduleInfoItemObject.h"
@interface LSLCLiveChatItem2OCObj : NSObject

#pragma mark - 公共处理
/**
 *  list<string>转NSArray
 *
 *  @param strList list<string>
 *
 *  @return NSString的NSArray
 */
+ (NSArray<NSString*>* _Nonnull)getStringArray:(const list<string>&)strList;

/**
 *  NSArray转list<string>
 *
 *  @param strArray NSString的NSArray
 *
 *  @return list<string>
 */
+ (list<string>)getStringList:(NSArray<NSString*>* _Nonnull)strArray;

#pragma mark - user object
/**
 *  获取用户object
 *
 *  @param userItem 用户item
 *
 *  @return 用户object
 */
+ (LSLCLiveChatUserItemObject* _Nullable)getLiveChatUserItemObject:(const LSLCUserItem* _Nullable)userItem;

/**
 *  获取用户object数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户object数组
 */
+ (NSArray<LSLCLiveChatUserItemObject*>* _Nonnull)getLiveChatUserArray:(const LCUserList&)userList;

/**
 *  获取用户ID数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户ID数组
 */
+ (NSArray<NSString*>* _Nonnull)getLiveChatUserIdArray:(const LCUserList&)userList;

#pragma mark - message object
/**
 *  获取消息object
 *
 *  @param msgItem 消息item
 *
 *  @return 消息object
 */
+ (LSLCLiveChatMsgItemObject* _Nullable)getLiveChatMsgItemObject:(const LSLCMessageItem* _Nullable)msgItem;

/**
 *  获取消息object
 *
 *  @param msgItem 消息item(非指针)
 *
 *  @return 消息object
 */
+ (LSLCLiveChatMsgItemObject* _Nullable)getLiveChatLastMsgItemObject:(const LSLCMessageItem&)msgItem;

/**
 *  获取消息object数组
 *
 *  @param msgList 消息item list
 *
 *  @return 消息object数组
 */
+ (NSArray<LSLCLiveChatMsgItemObject*>* _Nonnull)getLiveChatMsgArray:(const LCMessageList&)msgList;

#pragma mark - message item
/**
 *  获取消息item
 *
 *  @param msg 消息object
 *
 *  @return 消息item
 */
+ (LSLCMessageItem* _Nullable)getLiveChatMsgItem:(LSLCLiveChatMsgItemObject* _Nonnull)msg;

#pragma mark - userinfo item
/**
 *  获取用户信息object
 *
 *  @param userInfo 用户信息item
 *
 *  @return 用户信息object
 */
+ (LSLCLiveChatUserInfoItemObject* _Nullable)getLiveChatUserInfoItemObjecgt:(const UserInfoItem&)userInfo;

/**
 *  获取用户信息object数组
 *
 *  @param userInfoList 用户信息item list
 *
 *  @return 用户信息object数组
 */
+ (NSArray<LSLCLiveChatUserInfoItemObject*>* _Nonnull)getLiveChatUserInfoArray:(const UserInfoList&)userInfoList;

#pragma mark - Emotion item
/**
 * 获取高级表情信息object
 *
 * @param EmotionItem 高级表情item
 *
 * @return 高级表情信息object
 */
+ (LSLCLiveChatEmotionItemObject* _Nullable)getLiveChatEmotionItemObject:(const LSLCEmotionItem* _Nullable)EmotionItem;

/**
 * 获取高级表情配置object
 *
 * @param otherEmotionItem 高级表情配置item
 *
 * @return 高级表情配置信息object
 */
+ (LSLCLiveChatEmotionConfigItemObject* _Nullable)getLiveChatEmotionConfigItemObject:(const LSLCOtherEmotionConfigItem&)otherEmotionItem;

#pragma mark - MagicIcon item
/**
 * 获取小高级表情信息object
 *
 * @param EmotionItem 小高级表情item
 *
 * @return 小高级表情信息object
 */
+ (LSLCLiveChatMagicIconItemObject* _Nullable)getLiveChatMagicIconItemObject:(const LSLCMagicIconItem* _Nullable)magicIconItem;

/**
 * 获取小高级表情配置object
 *
 * @param magicConfig 小高级表情配置item
 *
 * @return 小高级表情配置信息object
 */
+ (LSLCLiveChatMagicIconConfigItemObject* _Nullable)getLiveChatMagicIconConfigItemObject:(const LSLCMagicIconConfig&)magicConfig;

/**
 * 获取语音消息object
 *
 * @param voiceItem 语音item
 *
 * @return 语音消息object
 */
+ (LSLCLiveChatMsgVoiceItem* _Nullable)getLiveChatVoiceItemObject:(const LSLCVoiceItem*_Nullable)voiceItem;

/**
 * 获取视频消息object
 *
 * @param videoItem 视频item
 *
 * @return 视频消息object
 */
+ (LSLCLiveChatMsgVideoItem* _Nullable)getLiveChatVideoItemObject:(const lcmm::LSLCVideoItem*_Nullable)videoItem;

/**
 * 预约信息object
 *
 * @param msgItem 预约信息
 *
 * @return 预约信息object
 */
+ (LSLCLiveChatScheduleInfoItemObject* _Nullable)getLiveChatScheduleInfoItemObject:(const LSLCScheduleInfoItem& )msgItem;

+ (LSLCScheduleInviteItem* _Nullable)getLiveChatScheduleInviteItem:(LSLCLiveChatScheduleMsgItemObject*_Nonnull)scheduleItem;

@end
