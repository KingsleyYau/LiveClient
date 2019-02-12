//
//  LSLCLiveChatTextItemObject.h
//  dating
//
//  Created by  Samson on 5/17/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//  LiveChat文本消息item类

#import <Foundation/Foundation.h>

@interface LSLCLiveChatTextItemObject : NSObject

/** 消息内容 */
@property (nonatomic,strong) NSString* message;
/** 用于显示的消息内容 */
@property (nonatomic,strong) NSString* displayMsg;
/** 内容是否非法 */
@property (nonatomic,assign) BOOL illegal;

/**
 *  初始化
 *
 *  @return this
 */
- (LSLCLiveChatTextItemObject*)init;

@end
