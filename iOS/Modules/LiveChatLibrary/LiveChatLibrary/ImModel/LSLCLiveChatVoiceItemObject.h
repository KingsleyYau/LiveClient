//
//  LSLCLiveChatVoiceItemObject.h
//  dating
//
//  Created by alex on 17/5/2.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCLiveChatVoiceItemObject : NSObject

/** 语音消息ID */
@property (nonatomic,copy) NSString *voiceId;
/** 语音消息路径 */
@property (nonatomic,copy) NSString *filePath;
/** 语音时间长度（单位秒） */
@property (nonatomic,assign) NSInteger timeLength;
/** 语音类型 */
@property (nonatomic,copy) NSString *fileType;
/** 语音验证码 */
@property (nonatomic,copy) NSString *checkCode;
/** 是否收费 */
@property (nonatomic,assign) BOOL charge;
/** 是否在处理 */
@property (nonatomic,assign) BOOL processing;

//初始化
- (LSLCLiveChatVoiceItemObject *)init;


@end
