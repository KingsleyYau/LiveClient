//
//  LMHandleHttpListener.h
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LMHeader.h"
#include "ImClient/IImClientDef.h"

@protocol LMHandleHttpListenerDelegate <NSObject>
@optional

// ---------- http 私信调用(只在LSPrivateMessageManager调用，其他地方不调用) --------------
// 调用http接口获取私信联系人列表（只在LSPrivateMessageManager调用，其他地方不调用）
- (long long) onHandlePrivateMsgFriendListRequest:(long)callback;

// 调用http接口获取私信关注联系人列表（只在LSPrivateMessageManager调用，其他地方不调用）
- (long long) onHandleFollowPrivateMsgFriendListRequest:(long)callback;

// 调用http接口获取私信消息列表（只在LSPrivateMessageManager调用，其他地方不调用）
- (void) onHandlePrivateMsgWithUserIdRequest:(NSString * _Nonnull)userId startMsgId:(NSString * _Nonnull)startMsgId order:(PrivateMsgOrderType)order limit:(int)limit reqId:(int)reqId callback:(long)callback;

// 调用http接口设置已读私信消息（只在LSPrivateMessageManager调用，其他地方不调用）
- (long long) onHandleSetPrivateMsgReadedRequest:(NSString * _Nonnull)userId msgId:(NSString * _Nonnull)msgId callback:(long)callback;

@end
