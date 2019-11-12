//
//  LSMessage.h
//  livestream
//
//  Created by Calvin on 2018/6/19.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSPrivateMessageManager.h"

@interface LSMessage : NSObject

#pragma mark - 界面数据
@property (nonatomic, assign) int sendMsgId;
@property (nonatomic, strong) NSAttributedString* attText;
@property (nonatomic, copy) NSString* text;
/**
 *  接收/发送时间
 */
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) LMSendType sendType;
@property (nonatomic, assign) LMStatusType statusType;
@property (nonatomic, assign) LCC_ERR_TYPE sendErr;
@property (nonatomic, assign) LMMessageType msgType;
@property (nonatomic, strong) LMPrivateMsgContactObject*  userItem;
@property (nonatomic, strong) LMPrivateMsgItemObject*  privateItem;
@property (nonatomic, strong) LMSystemNoticeItemObject*  systemItem;
@property (nonatomic, strong) LMWarningItemObject*  warningItem;
@property (nonatomic, strong) LMTimeMsgItemObject*  timeMsgItem;

@end
