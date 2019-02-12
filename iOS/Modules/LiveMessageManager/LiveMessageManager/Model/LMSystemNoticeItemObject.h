//
// LMPrivateMsgItemObject.h
//  dating
//
//  Created by Alex on 18/6/25.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ILiveMessageDef.h"
@interface LMSystemNoticeItemObject : NSObject
/**
 * 私信系统信息
 * message     私信系统内容
 */
@property (nonatomic, copy) NSString* _Nonnull message;
@property (nonatomic, assign) LMSystemType systemType;

@end
