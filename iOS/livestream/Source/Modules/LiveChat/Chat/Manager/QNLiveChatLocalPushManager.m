//
//  LiveChatLocalPushManager.m
//  dating
//
//  Created by Calvin on 17/8/10.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNLiveChatLocalPushManager.h"
#import "LiveUrlHandler.h"

@interface QNLiveChatLocalPushManager () <LSLiveChatManagerListenerDelegate>
@property (nonatomic, strong) NSMutableArray *msgArray;
@end

@implementation QNLiveChatLocalPushManager

+ (QNLiveChatLocalPushManager *)sharedInstance {
    static QNLiveChatLocalPushManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];

    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[LSLiveChatManagerOC manager] addDelegate:self];
        self.msgArray = [NSMutableArray array];
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

- (void)onRecvVideo:(LSLCLiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pushMessageFromLady:msgItem];
    });
}

- (NSString *)getPushMessage:(LSLCLiveChatMsgItemObject *)msgObj fromUserName:(NSString *)name {
    NSString *message = @"";
    if (msgObj.msgType == MT_Text) {
        message = [NSString stringWithFormat:@"%@", [LSStringEncoder htmlEntityDecode:msgObj.textMsg.displayMsg]];
    } else if (msgObj.msgType == MT_Photo) {
        message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"NOTICE_MESSAGE_PHOTO", nil)];
    } else if (msgObj.msgType == MT_Voice) {
        message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"NOTICE_MESSAGE_VOICE", nil)];
    } else if (msgObj.msgType == MT_Video) {
        message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"NOTICE_MESSAGE_VIDEO", nil)];
    } else if (msgObj.msgType == MT_Emotion) {
        message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"NOTICE_MESSAGE_ANIMATING_STICKER", nil)];
    } else if (msgObj.msgType == MT_MagicIcon) {
        message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"NOTICE_MESSAGE_PREMIUM_STICKER", nil)];
    } else {
        message = [NSString stringWithFormat:@"%@", NSLocalizedString(@"NOTICE_MESSAGE_TEXT", nil)];
    }
    return message;
}

- (void)pushMessageFromLady:(LSLCLiveChatMsgItemObject *)msgObj {
    [self.msgArray addObject:msgObj];
    [[LSLiveChatManagerOC manager] getUserInfo:msgObj.fromId];
}

- (void)onGetUserInfo:(LSLIVECHAT_LCC_ERR_TYPE)errType errMsg:(NSString *)errMsg userId:(NSString *)userId userInfo:(LSLCLiveChatUserInfoItemObject *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!userInfo) {
            NSLog(@"QNLiveChatLocalPushManager::onGetUserInfo 失败，不显示");
            return;
        }
        int row = 0;
        BOOL isDelete = NO;
        for (int i = 0; i < self.msgArray.count; i++) {
            row = i;
            LSLCLiveChatMsgItemObject *msgItem = [self.msgArray objectAtIndex:i];
            if ([msgItem.fromId isEqualToString:userId]) {
                isDelete = YES;
                NSString *message = [self getPushMessage:msgItem fromUserName:userInfo.userName];
                if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                    [self backgroundApp:msgItem msg:message userInfo:userInfo];
                } else {
                    [self activeApp:msgItem msg:message userInfo:userInfo userID:userId];
                }
                break;
            }
        }
        if (isDelete) {
            @synchronized(self.msgArray) {
                [self.msgArray removeObjectAtIndex:row];
            }
        }
    });
}

- (void)activeApp:(LSLCLiveChatMsgItemObject *)msgItem msg:(NSString *)message userInfo:(LSLCLiveChatUserInfoItemObject *)userInfo userID:(NSString *)userId {
    LSLCLiveChatUserItemObject *userItem = [[LSLiveChatManagerOC manager] getUserWithId:userId];
    userItem.imageUrl = userInfo.avatarImg;
    userItem.userName = userInfo.userName;

    if ([self.delegate respondsToSelector:@selector(liveChatPushManager:andMsgItem:formLady:)]) {
        [self.delegate liveChatPushManager:message andMsgItem:msgItem formLady:userItem];
    }
}

- (void)backgroundApp:(LSLCLiveChatMsgItemObject *)msgItem msg:(NSString *)message userInfo:(LSLCLiveChatUserInfoItemObject *)userInfo {
    if ([[LSLiveChatManagerOC manager] isChatingUserInChatState:msgItem.fromId]) {

        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];

        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:@"%@: %@", userInfo.userName, message];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.userInfo = @{ @"jumpurl" : [[[LiveUrlHandler shareInstance] createLiveChatByanchorId:msgItem.fromId anchorName:userInfo.userName] absoluteString] };
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
            notification.repeatInterval = NSCalendarUnitDay;
        } else {
            notification.repeatInterval = NSCalendarUnitDay;
        }

        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
