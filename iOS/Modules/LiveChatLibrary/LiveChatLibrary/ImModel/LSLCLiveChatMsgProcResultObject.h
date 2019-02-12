//
//  LSLCLiveChatMsgProcResultObject.h
//  dating
//
//  Created by  Samson on 6/3/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat消息item的处理结果类

#import <Foundation/Foundation.h>
#include <livechatmanmanager/ILSLiveChatManManagerEnumDef.h>

@interface LSLCLiveChatMsgProcResultObject : NSObject
/** 处理结果类型 */
@property (nonatomic,assign) LSLIVECHAT_LCC_ERR_TYPE errType;
/** 处理结果代码 */
@property (nonatomic,strong) NSString* errNum;
/** 处理结果描述 */
@property (nonatomic,strong) NSString* errMsg;

- (LSLCLiveChatMsgProcResultObject*)init;
@end
