//
//  LiveChatCustomItemObject.h
//  dating
//
//  Created by  Samson on 5/28/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat自定义消息item类

#import <Foundation/Foundation.h>

@interface LiveChatCustomItemObject : NSObject
/** 消息内容 */
@property (nonatomic,assign) NSInteger param;

/**
 *  初始化
 *
 *  @return this
 */
- (LiveChatCustomItemObject*)init;
@end
