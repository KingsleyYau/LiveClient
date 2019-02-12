//
//  LSLCLiveChatUserInfoItemObject.h
//  dating
//
//  Created by  Samson on 5/30/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat用户信息类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILSLiveChatManManagerEnumDef.h>

@interface LSLCLiveChatUserInfoItemObject : NSObject

/** 用户ID */
@property (nonatomic,copy) NSString* userId;
/** 用户名 */
@property (nonatomic,copy) NSString* userName;
/** 服务器名 */
@property (nonatomic,copy) NSString* server;
/** 头像URL */
@property (nonatomic,copy) NSString* imgUrl;
/** 小头像URL */
@property (nonatomic,copy) NSString* avatarImg;
/** 性别 */
@property (nonatomic,assign) USER_SEX_TYPE sexType;
/** 年龄 */
@property (nonatomic,assign) NSInteger age;
/** 体重 */
@property (nonatomic,copy) NSString* weight;
/** 身高 */
@property (nonatomic,copy) NSString* height;
/** 国家 */
@property (nonatomic,copy) NSString* country;
/** 省份 */
@property (nonatomic,copy) NSString* province;
/** 视频聊天 */
@property (nonatomic,assign) BOOL videoChat;
/** 视频数量 */
@property (nonatomic,assign) NSInteger videoCount;
/** 婚姻状况 */
@property (nonatomic,assign) MARRY_TYPE marryType;
/** 子女状况 */
@property (nonatomic,assign) CHILDREN_TYPE childrenType;
/** 用户在线状态 */
@property (nonatomic,assign) USER_STATUS_TYPE status;
/** 用户类型 */
@property (nonatomic,assign) USER_TYPE userType;
/** 排序分值 */
@property (nonatomic,assign) NSInteger orderValue;
/** 设备类型 */
@property (nonatomic,assign) TDEVICE_TYPE deviceType;
/** 客户端类型 */
@property (nonatomic,assign) CLIENT_TYPE clientType;
/** 客户端版本号 */
@property (nonatomic,copy) NSString* clientVersion;
/** 是否需要翻译 */
@property (nonatomic,assign) BOOL needTrans;
/** 翻译ID */
@property (nonatomic,copy) NSString* transUserId;
/** 翻译名称 */
@property (nonatomic,copy) NSString* transUserName;
/** 是否绑定翻译 */
@property (nonatomic,assign) BOOL transBind;
/** 翻译在线状态 */
@property (nonatomic,assign) USER_STATUS_TYPE transStatus;

- (LSLCLiveChatUserInfoItemObject*)init;

@end
