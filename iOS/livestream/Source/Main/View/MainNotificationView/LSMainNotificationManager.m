//
//  LSMainNotificationManager.m
//  livestream
//
//  Created by Calvin on 2019/1/17.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSMainNotificationManager.h"
#import "QNLiveChatLocalPushManager.h"
#import "LiveModule.h"
#import "LSImManager.h"
#import "LSGetHangoutFriendsRequest.h"
#import "LSAutoInvitationHangoutLiveDisplayRequest.h"
//显示冒泡最大数
#define SHOW_MAX_NUM 8
//显示聊天消息的最大数
#define SHOW_CHAT_MAX_NUM 4
//显示直播消息的最大数
#define SHOW_LIVE_MAX_NUM SHOW_MAX_NUM - SHOW_CHAT_MAX_NUM
//缓存最大数
#define CACHE_MAX_NUM 4
//超时消失时间
#define TIMEOUT 45.0
//延迟显示i气泡时间
#define DELAY_TIME 5.0

static LSMainNotificationManager *mainNotificationManager = nil;

@interface LSMainNotificationManager () <QNLiveChatLocalPushManagerDelegate, IMManagerDelegate>
@property (nonatomic, strong) NSMutableArray *cacheArray; //缓存数据数组
@property (nonatomic, strong) NSMutableArray *showArray;  //显示气泡数组
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *hangoutDic;
@property (nonatomic, assign) BOOL isRequestEnd; //是否请求完成
@property (nonatomic, assign) NSInteger time;
@end

@implementation LSMainNotificationManager

+ (instancetype)manager {
    if (mainNotificationManager == nil) {
        mainNotificationManager = [[[self class] alloc] init];
    }
    return mainNotificationManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cacheArray = [NSMutableArray array];
        self.showArray = [NSMutableArray array];
        self.hangoutDic = [NSMutableDictionary dictionary];
        [QNLiveChatLocalPushManager sharedInstance].delegate = self;
        [[LSImManager manager] addDelegate:self];
        self.isRequestEnd = YES;
    }
    return self;
}

- (void)newCountdown {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    }
}

- (void)stopCountdown {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)countdown {

    if (self.showArray.count == 0 && self.cacheArray.count == 0) {
        NSLog(@"LSMainNotificationManager::没有气泡和缓存数据，停止倒计时");
        [self stopCountdown];
        if ([self.delegate respondsToSelector:@selector(mainNotificationManagerRemoveNotificaitonView)]) {
            [self.delegate mainNotificationManagerRemoveNotificaitonView];
            return;
        }
    } else if (self.showArray.count == 0 && self.cacheArray.count > 0) {
        [self showNotificaitonView];
    } else {
        @synchronized(self.showArray) {
            BOOL isTimeOut = NO;
            NSInteger row = 0;
            for (int i = 0; i < self.showArray.count; i++) {
                LSMainNotificaitonModel *model = self.showArray[i];
                if ([[NSDate date] timeIntervalSince1970] - [self timeOutNum] > model.createTime) {
                    NSLog(@"LSMainNotificationManager::countdown 气泡显示到期 Msg:%@ userId:%@ msgType:%@ time:%ld", model.contentStr, model.userId, model.msgType == MsgStatus_Chat ? @"Chat" : @"Hangout", (long)model.createTime);
                    isTimeOut = YES;
                    row = i;
                    break;
                }
            }
            if (isTimeOut) {
                LSMainNotificaitonModel *model = self.showArray[row];
                [self.showArray removeObject:model];

                if (self.showArray.count > 0) {
                    //刷新UI
                    [self hideTimeoutNotificaitonView:model];
                }
            }
            self.time++;
            if (self.showArray.count < SHOW_MAX_NUM && self.time > 5) {
                self.time = 0;
                [self showNotificaitonView];
            }
        }
    }
}

- (CGFloat)timeOutNum {
    return TIMEOUT;
}

//插入缓存通知数据
- (void)insertCacheNotificaiton:(LSMainNotificaitonModel *)model {
    @synchronized(self.cacheArray) {
        if (self.cacheArray.count > CACHE_MAX_NUM) {
            NSLog(@"LSMainNotificationManager::cacheArray超过最大数，删除第一条数据 Msg:%@ userId:%@ msgType:%@ time:%ld", model.contentStr, model.userId, model.msgType == MsgStatus_Chat ? @"Chat" : @"Hangout", (long)model.createTime);
            [self removeCacheFirstObject];
        }
        NSLog(@"LSMainNotificationManager::插入缓存数据 Msg:%@ userId:%@ msgType:%@ time:%ld", model.contentStr, model.userId, model.msgType == MsgStatus_Chat ? @"Chat" : @"Hangout", (long)model.createTime);
        [self.cacheArray addObject:model];
    }
    //开始倒计时
    [self newCountdown];
}

//获取显示数组类型个数
- (NSInteger)getShowMsgTypeNumIsChat:(BOOL)isChat {
    NSInteger chatNum = 0;
    NSInteger liveNum = 0;
    @synchronized(self.showArray) {
        for (LSMainNotificaitonModel *model in self.showArray) {
            if (model.msgType == MsgStatus_Chat) {
                chatNum++;
            } else {
                liveNum++;
            }
        }
    }
    return isChat ? chatNum : liveNum;
}

//添加到显示数组并回调显示UI
- (void)addDataToShowArrayAndCallbackDelegate:(LSMainNotificaitonModel *)model {
    NSLog(@"LSMainNotificationManager::添加到显示数组并回调显示UI Msg:%@ userId:%@ msgType:%@ time:%ld", model.contentStr, model.userId, model.msgType == MsgStatus_Chat ? @"Chat" : @"Hangout", (long)model.createTime);
    //可显示
    @synchronized(self) {
        [self.showArray insertObject:model atIndex:0];
        [self.cacheArray removeObject:model];
    }
    [self delayCallbackDelegate:model];
}

//删除没用的缓存消息
- (void)removeCacheFirstObject {
    NSLog(@"LSMainNotificationManager::removeCacheFirstObject 删除第一条数据");
    @synchronized(self) {
        if (self.cacheArray.count > 0) {
            [self.cacheArray removeObjectAtIndex:0];
        }
    }
}

//更新本地hangout数组时间
- (void)updateHangoutLocationArray:(LSMainNotificaitonModel *)model {
    NSLog(@"LSMainNotificationManager::updateHangoutLocationArray 更新本地hangout通知时间 %ld", model.createTime);

    [self.hangoutDic setObject:[NSNumber numberWithInteger:model.createTime] forKey:model.userId];
}

//延时通知
- (void)delayCallbackDelegate:(LSMainNotificaitonModel *)model {
    CGFloat delay = self.showArray.count == 1 ? 0 : DELAY_TIME;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //更新实际显示时间
        model.createTime = [[NSDate date] timeIntervalSince1970];
        if (model.msgType == MsgStatus_Hangout) {
            [self updateHangoutLocationArray:model];
        } else {
            [[LiveModule module].analyticsManager reportActionEvent:ShowLiveChatInvitation eventCategory:EventCategoryLiveChat];
        }
        NSLog(@"LSMainNotificationManager::延时了%0.fs 显示气泡  Msg:%@ userId:%@ msgType:%@ time:%ld", delay, model.contentStr, model.userId, model.msgType == MsgStatus_Chat ? @"Chat" : @"Hangout", (long)model.createTime);
        //刷新UI
        if ([weakSelf.delegate respondsToSelector:@selector(mainNotificationManagerShowNotificaitonView:)]) {
            [weakSelf.delegate mainNotificationManagerShowNotificaitonView:model];
        }
    });
}

//显示气泡逻辑
- (void)showNotificaitonView {
    if (self.cacheArray.count > 0) {
        LSMainNotificaitonModel *model = [self.cacheArray objectAtIndex:0];
        if (model.msgType == MsgStatus_Chat) {
            if ([self getShowMsgTypeNumIsChat:YES] < SHOW_CHAT_MAX_NUM) {
                [self addDataToShowArrayAndCallbackDelegate:model];
            }
        } else {
            if ([self getShowMsgTypeNumIsChat:NO] < SHOW_LIVE_MAX_NUM) {
                NSNumber *createTime = [self.hangoutDic objectForKey:model.userId];
                NSInteger time = [createTime integerValue];
                if (createTime && time + 600 > [[NSDate date] timeIntervalSince1970]) {
                    //10分鐘内顯示过該主播的邀请
                    NSLog(@"LSMainNotificationManager::showNotificaitonView  10分鐘内顯示过該主播hangout邀请，不插入气泡");
                    //删除没用的缓存消息
                    [self removeCacheFirstObject];
                    return;
                }

                if (self.isRequestEnd) {
                    self.isRequestEnd = NO;
                    LSAutoInvitationHangoutLiveDisplayRequest *request = [[LSAutoInvitationHangoutLiveDisplayRequest alloc] init];
                    request.anchorId = model.userId;
                    request.isAuto = model.isAuto;
                    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.isRequestEnd = YES;
                            NSLog(@"LSMainNotificationManager::showNotificaitonView LSAutoInvitationHangoutLiveDisplayRequest hangout消息是否显示 %@", BOOL2SUCCESS(success));
                            if (success) {
                                [self addDataToShowArrayAndCallbackDelegate:model];
                            } else {
                                //删除没用的缓存消息
                                [self removeCacheFirstObject];
                            }
                        });
                    };
                    [[LSSessionRequestManager manager] sendRequest:request];
                }
            }
        }
    }
}

//删除过期气泡
- (void)hideTimeoutNotificaitonView:(LSMainNotificaitonModel *)model {
    NSLog(@"LSMainNotificationManager::hideTimeoutNotificaitonView 移除气泡 Msg:%@ userId:%@ msgType:%@ time:%ld", model.contentStr, model.userId, model.msgType == MsgStatus_Chat ? @"Chat" : @"Hangout", (long)model.createTime);
    if ([self.delegate respondsToSelector:@selector(mainNotificationManagerHideNotificaitonView:)]) {
        [self.delegate mainNotificationManagerHideNotificaitonView:model];
    }
}

//点击选中气泡并移除
- (void)selectedShowArrayRowItem:(LSMainNotificaitonModel *)item {
    NSInteger row = 0;
    for (int i = 0; i < self.showArray.count; i++) {
        LSMainNotificaitonModel *model = self.showArray[i];
        if ([model.contentStr isEqualToString:item.contentStr] && [model.userId isEqualToString:item.userId]) {
            NSLog(@"LSMainNotificationManager::selectedShowArrayRow 选中气泡 Msg:%@ userId:%@ msgType:%@ time:%ld", model.contentStr, model.userId, model.msgType == MsgStatus_Chat ? @"Chat" : @"Hangout", (long)model.createTime);
            row = i;
            break;
        }
    }

    @synchronized(self.showArray) {
        if (row < self.showArray.count) {
            [self.showArray removeObjectAtIndex:row];
        }
    }

    if ([self.delegate respondsToSelector:@selector(mainNotificationManagerRemoveselectedItem)]) {
        [self.delegate mainNotificationManagerRemoveselectedItem];
    }
}

#pragma mark - 收到liveChat消息
- (void)liveChatPushManager:(NSString *)msg andMsgItem:(LSLCLiveChatMsgItemObject *)msgObj formLady:(LSLCLiveChatUserItemObject *)userItem {
    //在聊消息不显示
    if ([[LSLiveChatManagerOC manager] isChatingUserInChatState:userItem.userId]) {
        return;
    }
    NSLog(@"LSMainNotificationManager::liveChatPushManager Msg:%@ userId:%@", msg, userItem.userId);

    LSMainNotificaitonModel *model = [[LSMainNotificaitonModel alloc] init];
    model.userName = userItem.userName;
    model.userId = userItem.userId;
    model.photoUrl = userItem.imageUrl;
    model.contentStr = msg;
    model.msgType = MsgStatus_Chat;
    [self insertCacheNotificaiton:model];
}

#pragma mark - 收到hangout邀请通知
- (void)onRecvHandoutInviteNotice:(IMHangoutInviteItemObject *)item {

    NSLog(@"LSMainNotificationManager::onRecvHandoutInviteNotice anchorNickName: %@,anchorId : %@ InviteMessage: %@", item.anchorNickName, item.anchorId, item.InviteMessage);

    dispatch_async(dispatch_get_main_queue(), ^{
        LSGetHangoutFriendsRequest *request = [[LSGetHangoutFriendsRequest alloc] init];
        request.anchorId = item.anchorId;
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *anchorId, NSArray<LSHangoutAnchorItemObject *> *array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"LSMainNotificationManager::LSGetHangoutFriendsRequest:%@,errnum : %d, errmsg : %@", BOOL2SUCCESS(success), errnum, errmsg);
                if (array.count > 0) {
                    int r = arc4random() % [array count];
                    LSHangoutAnchorItemObject *ojb = [array objectAtIndex:r];
                    LSMainNotificaitonModel *model = [[LSMainNotificaitonModel alloc] init];
                    model.userName = item.anchorNickName;
                    model.userId = item.anchorId;
                    model.photoUrl = item.avatarImg;
                    model.contentStr = item.InviteMessage;
                    model.msgType = MsgStatus_Hangout;
                    model.friendUrl = ojb.photoUrl;
                    model.isAuto = NO;
                    [self insertCacheNotificaiton:model];
                }else {
                    NSLog(@"LSMainNotificationManager::LSGetHangoutFriendsRequest: 没有好友数据不插入");
                }
            });
        };
        [[LSSessionRequestManager manager] sendRequest:request];
    });
}

@end
