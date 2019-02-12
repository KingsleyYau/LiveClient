//
//  LiveChatUserItemObject.h
//  dating
//
//  Created by lance on 16/4/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  LiveChat用户item类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILiveChatManManagerEnumDef.h>


@class LiveChatMsgItemObject;

@interface LiveChatUserItemObject : NSObject
/** 用户ID */
@property (nonatomic, strong) NSString *userId;
/** 用户名  */
@property (nonatomic, strong) NSString *userName;
/** 头像URL */
@property (nonatomic, strong) NSString *imageUrl;
/** 用户性别 */
@property (nonatomic, assign) USER_SEX_TYPE sexType;
/** 客户端类型 */
@property (nonatomic, assign) CLIENT_TYPE clientType;
/** 在线状态 */
@property (nonatomic, assign) USER_STATUS_TYPE statusType;
/** 聊天状态 */
@property (nonatomic, assign) Chat_Type chatType;
/** 邀请ID */
@property (nonatomic, strong) NSString *inviteId;
/** 是否正在尝试发送 */
@property (nonatomic, assign) BOOL tryingSend;
/** 排序分值 */
@property (nonatomic, assign) int order;
/** 视频是否开启 */
@property (nonatomic, assign) BOOL isOpenCam;
/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatUserItemObject*)init;
@end
