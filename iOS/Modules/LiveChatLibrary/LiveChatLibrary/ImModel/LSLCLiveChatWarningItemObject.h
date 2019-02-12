//
//  LSLCLiveChatWarningItemObject.h
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat警告消息item类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILSLiveChatManManagerEnumDef.h>

/**
 *  警告消息的链接
 */
@interface LSLCLiveChatWarningLinkItemObject : NSObject
/** 链接文字内容 */
@property (nonatomic,strong) NSString* linkMsg;
/** 链接操作类型 */
@property (nonatomic,assign) LinkOptType linkOptType;

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatWarningLinkItemObject*)init;
@end


/**
 *  警告消息
 */
@interface LSLCLiveChatWarningItemObject : NSObject
/** 消息类型 */
@property (nonatomic,assign) WarningCodeType codeType;
/** 消息内容 */
@property (nonatomic,strong) NSString* message;
/** 链接 */
@property (nonatomic,strong) LSLCLiveChatWarningLinkItemObject* link;

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatWarningItemObject*)init;
@end
