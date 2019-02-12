//
//  LiveChatItem2OCObj.h
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILiveChatManManager.h>
#import "LiveChatUserItemObject.h"
#import "LiveChatMsgItemObject.h"
#import "LiveChatUserInfoItemObject.h"
#import "LiveChatMsgPhotoItem.h"
#import "LiveChatEmotionItemObject.h"
#import "LiveChatEmotionConfigItemObject.h"
#import "LiveChatMagicIconItemObject.h"
#import "LiveChatMagicIconConfigItemObject.h"
#import "LiveChatMsgVoiceItem.h"
@interface LiveChatItem2OCObj : NSObject

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
+ (LiveChatUserItemObject* _Nullable)getLiveChatUserItemObject:(const LCUserItem* _Nullable)userItem;

/**
 *  获取用户object数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户object数组
 */
+ (NSArray<LiveChatUserItemObject*>* _Nonnull)getLiveChatUserArray:(const LCUserList&)userList;

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
+ (LiveChatMsgItemObject* _Nullable)getLiveChatMsgItemObject:(const LCMessageItem* _Nullable)msgItem;

/**
 *  获取消息object数组
 *
 *  @param msgList 消息item list
 *
 *  @return 消息object数组
 */
+ (NSArray<LiveChatMsgItemObject*>* _Nonnull)getLiveChatMsgArray:(const LCMessageList&)msgList;

#pragma mark - message item
/**
 *  获取消息item
 *
 *  @param msg 消息object
 *
 *  @return 消息item
 */
+ (LCMessageItem* _Nullable)getLiveChatMsgItem:(LiveChatMsgItemObject* _Nonnull)msg;

#pragma mark - userinfo item
/**
 *  获取用户信息object
 *
 *  @param userInfo 用户信息item
 *
 *  @return 用户信息object
 */
+ (LiveChatUserInfoItemObject* _Nullable)getLiveChatUserInfoItemObjecgt:(const UserInfoItem&)userInfo;

/**
 *  获取用户信息object数组
 *
 *  @param userInfoList 用户信息item list
 *
 *  @return 用户信息object数组
 */
+ (NSArray<LiveChatUserInfoItemObject*>* _Nonnull)getLiveChatUserInfoArray:(const UserInfoList&)userInfoList;

#pragma mark - Emotion item
/**
 * 获取高级表情信息object
 *
 * @param EmotionItem 高级表情item
 *
 * @return 高级表情信息object
 */
+ (LiveChatEmotionItemObject* _Nullable)getLiveChatEmotionItemObject:(const LCEmotionItem* _Nullable)EmotionItem;

/**
 * 获取高级表情配置object
 *
 * @param otherEmotionItem 高级表情配置item
 *
 * @return 高级表情配置信息object
 */
+ (LiveChatEmotionConfigItemObject* _Nullable)getLiveChatEmotionConfigItemObject:(const OtherEmotionConfigItem&)otherEmotionItem;

#pragma mark - MagicIcon item
/**
 * 获取小高级表情信息object
 *
 * @param EmotionItem 小高级表情item
 *
 * @return 小高级表情信息object
 */
+ (LiveChatMagicIconItemObject* _Nullable)getLiveChatMagicIconItemObject:(const LCMagicIconItem* _Nullable)magicIconItem;

/**
 * 获取小高级表情配置object
 *
 * @param magicConfig 小高级表情配置item
 *
 * @return 小高级表情配置信息object
 */
+ (LiveChatMagicIconConfigItemObject* _Nullable)getLiveChatMagicIconConfigItemObject:(const MagicIconConfig&)magicConfig;

/**
 * 获取语音消息object
 *
 * @param voiceItem 语音item
 *
 * @return 语音消息object
 */
+ (LiveChatMsgVoiceItem* _Nullable)getLiveChatVoiceItemObject:(const LCVoiceItem*_Nullable)voiceItem;
@end
