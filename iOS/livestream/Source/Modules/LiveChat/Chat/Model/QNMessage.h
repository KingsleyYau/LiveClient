//
//  Message.h
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSLCLiveChatMsgItemObject.h"
//#import "MonthlyFeeTipItemObject.h"
#import "LSLiveChatRequestManager.h"

@interface QNMessage : NSObject

#pragma mark - 原始数据
@property (nonatomic, strong) LSLCLiveChatMsgItemObject *liveChatMsgItemObject;
// 已观看视频列表数据
@property (nonatomic, strong) LSLCRecentVideoItemObject *recentVideoItemObject;

///** 月费数据 */
//@property (nonatomic,strong) MonthlyFeeTipItemObject *monthLyFeeTipItemObject;

#pragma mark - 界面数据
@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, strong) NSAttributedString *attText;
@property (nonatomic, strong) NSString *text;
/**
 私密照数据
 */
@property (nonatomic, strong) UIImage *secretPhotoImage;
/**
 默认图片
 */
@property (nonatomic, strong) UIImage *emotionDefault;
/**
 播放图片数组
 */
@property (strong) NSArray<UIImage *> *emotionAnimationArray;

@property (nonatomic, assign) CGFloat cellH;

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
    MessageTypeText,
    MessageTypePhoto,
    MessageTypeVoice,
    MessageTypeLargeEmotion,
    MessageTypeSmallEmotion,
    MessageTypeCoupon,
    MessageTypeVideo,
} Type;
@property (nonatomic, assign) Type type;

typedef enum {
    MessageStatusUnknow = 0,
    MessageStatusProcessing,
    MessageStatusFinish,
    MessageStatusFail,
} Status;

@property (nonatomic, assign) Status status;

+ (NSString *)htmlEntityDecode:(NSString *)string;
@end
