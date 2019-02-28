//
//  LiveChatLocalPushManager.m
//  dating
//
//  Created by Calvin on 17/8/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNLiveChatLocalPushManager.h"
#import "LiveUrlHandler.h"

@interface QNLiveChatLocalPushManager()<LSLiveChatManagerListenerDelegate>
@property (nonatomic, strong) LSLCLiveChatMsgItemObject * msgObj;
@end

@implementation QNLiveChatLocalPushManager

+ (QNLiveChatLocalPushManager *)sharedInstance
{
    static QNLiveChatLocalPushManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    
    });
    return sharedInstance;
}

- (instancetype)init
{
    if(self = [super init] ) {
        [[LSLiveChatManagerOC manager]addDelegate:self];
    }
    
    return self;
}

- (void)onRecvTextMsg:(LSLCLiveChatMsgItemObject *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushMessageFromLady:msg];
    });
}

- (void)onRecvPhoto:(LSLCLiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushMessageFromLady:msgItem];
    });
}

- (void)onRecvVoice:(LSLCLiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushMessageFromLady:msgItem];
    });
}

- (void)onRecvEmotion:(LSLCLiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushMessageFromLady:msgItem];
    });
}

- (void)onRecvMagicIcon:(LSLCLiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushMessageFromLady:msgItem];
    });
}


- (NSString *)getPushMessage:(LSLCLiveChatMsgItemObject*)msgObj fromUserName:(NSString *)name
{
    NSString * message = @"";
    if (msgObj.msgType == MT_Text) {
        message = [NSString stringWithFormat:@"%@",[LSStringEncoder htmlEntityDecode:msgObj.textMsg.displayMsg]];
    }
    else if (msgObj.msgType == MT_Photo)
    {
        message = [NSString stringWithFormat:@"%@ sent a photo.",name];
    }
    else if (msgObj.msgType == MT_Voice)
    {
        message = [NSString stringWithFormat:@"%@ sent a voice message.",name];
    }
    else if (msgObj.msgType == MT_Emotion)
    {
        message = [NSString stringWithFormat:@"%@ sent a animating sticker.",name];
    }
    else if (msgObj.msgType == MT_MagicIcon)
    {
        message = [NSString stringWithFormat:@"%@ sent a premium sticker.",name];
    }
    else
    {
        message = [NSString stringWithFormat:@"%@ sent a message.",name];
    }
    return message;
}

- (void)pushMessageFromLady:(LSLCLiveChatMsgItemObject *)msgObj
{
    self.msgObj = msgObj;
    [[LSLiveChatManagerOC manager] getUserInfo:msgObj.fromId];
    
}

- (void)onGetUserInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg userId:(NSString *)userId userInfo:(LSLCLiveChatUserInfoItemObject *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!userInfo) {
            return;
        }
        if ([self.msgObj.fromId isEqualToString:userId]) {
            NSString * message = [self getPushMessage:self.msgObj fromUserName:userInfo.userName];
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                if ([[LSLiveChatManagerOC manager]isChatingUserInChatState:self.msgObj.fromId]) {
                    
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
                    
                    UILocalNotification *notification = [[UILocalNotification alloc]init];
                    notification.alertBody = [NSString stringWithFormat:@"%@: %@",userInfo.userName,message];
                    notification.userInfo = @{@"jumpurl":[[[LiveUrlHandler shareInstance]createLiveChatByanchorId:self.msgObj.fromId anchorName:userInfo.userName] absoluteString]};
                    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                        UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;
                        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
                        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
                        notification.repeatInterval = NSCalendarUnitDay;
                    }else{
                        notification.repeatInterval = NSCalendarUnitDay;
                    }
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
            }
            else {
                LSLCLiveChatUserItemObject * userItem = [[LSLiveChatManagerOC manager]getUserWithId:userId];
                userItem.imageUrl = userInfo.avatarImg;
                userItem.userName = userInfo.userName;
                
                if ([self.delegate respondsToSelector:@selector(liveChatPushManager:andMsgItem:formLady:)]) {
                    [self.delegate liveChatPushManager:message andMsgItem:self.msgObj formLady:userItem];
                }
            }
        }
    });
}

@end