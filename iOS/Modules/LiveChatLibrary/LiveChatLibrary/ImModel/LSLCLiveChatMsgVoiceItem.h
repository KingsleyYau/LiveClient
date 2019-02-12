//
//  LSLCLiveChatMsgVoiceItem.h
//  dating
//
//  Created by Calvin on 17/4/25.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLCLiveChatMsgVoiceItem : NSObject

/** 语音ID */
@property (nonatomic,copy) NSString *voiceId;
/** 语音路径 */
@property (nonatomic,copy) NSString *filePath;
/** 语音类型 */
@property (nonatomic,copy) NSString *fileType;
/** 验证码 */
@property (nonatomic,copy) NSString *checkCode;
/** 语音长度 */
@property (nonatomic,assign) int timeLength;
/** 是否付费 */
@property (nonatomic,assign,getter=isGetCharge) BOOL charge;
/** 处理结果 */
@property (nonatomic,assign) BOOL processing;
/** 是否已读 */
@property (nonatomic,assign) BOOL isRead;
/** 是否播放中 */
@property (nonatomic,assign) BOOL isPalying;

- (LSLCLiveChatMsgVoiceItem *)init;


@end
