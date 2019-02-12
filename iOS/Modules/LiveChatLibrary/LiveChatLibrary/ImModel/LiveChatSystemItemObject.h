//
//  LiveChatSystemItemObject.h
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat系统消息item类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILiveChatManManagerEnumDef.h>

@interface LiveChatSystemItemObject : NSObject
/** 消息类型 */
@property (nonatomic,assign) CodeType codeType;
/** 消息内容 */
@property (nonatomic,strong) NSString* message;

/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatSystemItemObject*)init;
@end
