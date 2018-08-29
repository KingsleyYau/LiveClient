//
//  LSMessage.h
//  livestream
//
//  Created by Calvin on 2018/6/19.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSMessage : NSObject

#pragma mark - 界面数据
@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, strong) NSAttributedString* attText;
@property (nonatomic, copy) NSString* text;

typedef enum {
    MessageSenderUnknow = 0,
    MessageSenderLady,
    MessageSenderSelf,
} Sender;
@property (nonatomic, assign) Sender sender;

typedef enum {
    MessageTypeUnknow = 0,
    MessageTypeSystemTips,
    MessageTypeWarningTips,
    MessageTypeText
} Type;
@property (nonatomic, assign) Type type;

typedef enum {
    MessageStatusUnknow = 0,
    MessageStatusProcessing,
    MessageStatusFinish,
    MessageStatusFail,
} Status;

@property (nonatomic, assign) Status status;

@end
