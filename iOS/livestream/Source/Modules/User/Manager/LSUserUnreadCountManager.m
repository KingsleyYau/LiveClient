//
//  LSUserUnreadCountManager.m
//  livestream
//
//  Created by Calvin on 17/10/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSUserUnreadCountManager.h"
#import "LSLoginManager.h"
#import "GetTotalNoreadNumRequest.h"
#import "LSImManager.h"
#import "LSPrivateMessageManager.h"
#import "QNContactManager.h"

#define InvitationListUnread -1

static LSUserUnreadCountManager *unreadCountinstance;

@interface LSUserUnreadCountManager () <LoginManagerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate, LMMessageManagerDelegate, QNContactManagerDelegate>

@property (nonatomic, strong) NSMutableArray *delegates;
// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) TotalUnreadNumObject *unreadModel;

@property (nonatomic, strong) LSImManager *imManager;

@property (nonatomic, strong) LSPrivateMessageManager *messageManager;

@property (nonatomic, assign) BOOL isFirstLogin;
@end

@implementation LSUserUnreadCountManager

+ (instancetype _Nonnull)shareInstance {
    @synchronized(self) {
        if (unreadCountinstance == nil) {
            unreadCountinstance = [[LSUserUnreadCountManager alloc] init];
        }
        return unreadCountinstance;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFirstLogin = YES;

        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];

        self.imManager = [LSImManager manager];
        [self.imManager addDelegate:self];
        [self.imManager.client addDelegate:self];

        [[QNContactManager manager] addDelegate:self];

        self.sessionManager = [LSSessionRequestManager manager];

        self.messageManager = [LSPrivateMessageManager manager];
        [self.messageManager.client addDelegate:self];

        self.unreadModel = [[TotalUnreadNumObject alloc] init];
        self.delegates = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self.loginManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
    [[QNContactManager manager] removeDelegate:self];
    [self.messageManager.client removeDelegate:self];
}

- (void)addDelegate:(id<LSUserUnreadCountManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<LSUserUnreadCountManagerDelegate>)delegate {
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSUserUnreadCountManagerDelegate> item = (id<LSUserUnreadCountManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

// 代理回调
- (void)delegateToListener:(TotalUnreadNumObject *)item {
    @synchronized(self.delegates) {
        for (NSValue *value in self.delegates) {
            id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(reloadUnreadView:)]) {
                [delegate reloadUnreadView:item];
            }
        }
    }
}

#pragma mark - IM回调
- (void)onRecvLoiNotice:(NSString *)anchorId loiId:(NSString *)loiId {
    // TODO:接收意向信通知
    NSLog(@"LSUserUnreadCountManager::onRecvLoiNotice( [接收意向信通知], anchorId : %@, loiId : %@ )", anchorId, loiId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)onRecvEMFNotice:(NSString *)anchorId emfId:(NSString *)emfId {
    // TODO:接收EMF通知
    NSLog(@"LSUserUnreadCountManager::onRecvEMFNotice( [接收EMF通知], anchorId : %@, emfId : %@ )", anchorId, emfId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)onRecvBackpackUpdateNotice:(BackpackInfoObject *)item {
    // TODO:接收背包更新通知
    NSLog(@"LSUserUnreadCountManager::onRecvBackpackUpdateNotice( [接收背包更新通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)onRecvProgramPlayNotice:(IMProgramItemObject *)item type:(IMProgramNoticeType)type msg:(NSString *)msg {
    // TODO:接收节目开播通知
    NSLog(@"LSUserUnreadCountManager::onRecvProgramPlayNotice( [接收节目开播通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)onRecvScheduledInviteUserNotice:(NSString *_Nonnull)inviteId anchorId:(NSString *_Nonnull)anchorId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg msg:(NSString *_Nonnull)msg {
    // TODO:接收主播预约私密邀请通知
    NSLog(@"LSUserUnreadCountManager::onRecvProgramPlayNotice( [接收主播预约私密邀请通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)onRecvSendBookingReplyNotice:(ImBookingReplyObject *_Nonnull)item {
    // TODO:接收预约私密邀请回复通知
    NSLog(@"LSUserUnreadCountManager::onRecvProgramPlayNotice( [接收预约私密邀请回复通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)onRecvBookingNotice:(NSString *_Nonnull)roomId userId:(NSString *_Nonnull)userId nickName:(NSString *_Nonnull)nickName avatarImg:(NSString *_Nonnull)avatarImg leftSeconds:(int)leftSeconds {
    // TODO:接收预约开始倒数通知
    NSLog(@"LSUserUnreadCountManager::onRecvProgramPlayNotice( [接收预约开始倒数通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)onRecvPrivateMessage:(LMMessageItemObject *)item {
    NSLog(@"LSUserUnreadCountManager::onRecvPrivateMessage( [接收接收的私信消息] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

#pragma mark - HTTP请求
- (void)getResevationsUnredCount {
    // TODO:请求预约未读数
    ManBookingUnreadUnhandleNumRequest *request = [[ManBookingUnreadUnhandleNumRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, BookingUnreadUnhandleNumItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSUserUnreadCountManager::ManBookingUnreadUnhandleNumRequest( [请求预约未读数], %@, errnum : %d, errmsg : %@ )", success == YES ? @"成功" : @"失败", errnum, errmsg);
            @synchronized(self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetResevationsUnredCount:)]) {
                        [delegate onGetResevationsUnredCount:item];
                    }
                }
            }
        });
    };

    [self.sessionManager sendRequest:request];
}

- (void)getBackpackUnreadCount {
    // TODO:请求我的背包未读数
    GetBackpackUnreadNumRequest *request = [[GetBackpackUnreadNumRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, GetBackPackUnreadNumItemObject *_Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSUserUnreadCountManager::GetBackpackUnreadNumRequest( [请求我的背包未读数], %@, errnum : %d, errmsg : %@ )", success == YES ? @"成功" : @"失败", errnum, errmsg);
            @synchronized(self.delegates) {
                for (NSValue *value in self.delegates) {
                    id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                    if ([delegate respondsToSelector:@selector(onGetBackpackUnreadCount:)]) {
                        [delegate onGetBackpackUnreadCount:item];
                    }
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)getTotalUnreadNum:(GetTotalNoreadNumHandler)finshHandler {
    // TODO:获取主界面未读数量
    GetTotalNoreadNumRequest *request = [[GetTotalNoreadNumRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSMainUnreadNumItemObject *_Nullable userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSUserUnreadCountManager::GetTotalNoreadNumRequest( [获取主界面未读数量], %@, errnum : %d, errmsg : %@, userInfoItem : %@ )", BOOL2SUCCESS(success), errnum, errmsg, userInfoItem);
            if (success) {
                self.unreadModel.ticketNoreadNum = userInfoItem.showTicketUnreadNum;
                self.unreadModel.loiNoreadNum = userInfoItem.loiUnreadNum;
                self.unreadModel.emfNoreadNum = userInfoItem.emfUnreadNum;
                self.unreadModel.messageNoreadNum = userInfoItem.privateMessageUnreadNum;
                self.unreadModel.bookingNoreadNum = userInfoItem.bookingUnreadNum;
                self.unreadModel.backpackNoreadNum = userInfoItem.backpackUnreadNum + userInfoItem.livechatVocherUnreadNum;
                self.unreadModel.sayHiNoreadNum = userInfoItem.sayHiResponseUnreadNum;
                self.unreadModel.schedulePendingUnreadNum = userInfoItem.schedulePendingUnreadNum;
                self.unreadModel.scheduleConfirmedUnreadNum = userInfoItem.scheduleConfirmedUnreadNum;
                self.unreadModel.videoNum = userInfoItem.requestReplyUnreadNum;
                self.unreadModel.scheduleStatus = userInfoItem.scheduleStatus;
            }
            finshHandler(success, self.unreadModel);
        });
    };
    [self.sessionManager sendRequest:request];
}

- (int)getUnreadNum:(LSUnreadType)type {
    // TODO:获取指定类型未读消息
    int unreadNum = 0;
    switch (type) {
        case LSUnreadType_SayHi: { // SaiHi
            unreadNum = self.unreadModel.sayHiNoreadNum;
        } break;
        case LSUnreadType_Loi: { // Greetings
            unreadNum = self.unreadModel.loiNoreadNum;
        } break;
        case LSUnreadType_EMF: { // Mail
            unreadNum = self.unreadModel.emfNoreadNum;
        } break;
        case LSUnreadType_Private_Chat: { // Chat
            unreadNum = 0;
            NSInteger chatlistUnreadCount = [[QNContactManager manager] getChatListUnreadCount];
            if (chatlistUnreadCount > 0) {
                unreadNum = (int)chatlistUnreadCount;
            } else if ([QNContactManager manager].inviteItems.count > 0) {
                unreadNum = InvitationListUnread;
            }
        } break;
        case LSUnreadType_Hangout: { // Hangout
            unreadNum = 0;
        } break;
        case LSUnreadType_Ticket: { // Ticket
            unreadNum = self.unreadModel.ticketNoreadNum;
        } break;

        case LSUnreadType_Booking: { // Booking
            unreadNum = self.unreadModel.bookingNoreadNum;
        } break;
        case LSUnreadType_Schedule: { // schedule
            unreadNum = self.unreadModel.scheduleConfirmedUnreadNum + self.unreadModel.schedulePendingUnreadNum;
        } break;
        case LSUnreadType_Video: {
            unreadNum = self.unreadModel.videoNum;
        }break;
        case LSUnreadType_Backpack: { // BackPack
            unreadNum = self.unreadModel.backpackNoreadNum;
        } break;
        default: {
        } break;
    }
    return unreadNum;
}

- (LSScheduleStatus)getScheduleStatus {
    return self.unreadModel.scheduleStatus;
}

- (void)onChangeRecentContactStatus:(QNContactManager *)manager {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for (NSValue *value in self.delegates) {
                id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onGetChatlistUnreadCount:)]) {
                    [delegate onGetChatlistUnreadCount:[self getUnreadNum:LSUnreadType_Private_Chat]];
                }
            }
        }
    });
}

- (void)onChangeInviteList:(QNContactManager *)manager {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for (NSValue *value in self.delegates) {
                id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onGetChatlistUnreadCount:)]) {
                    [delegate onGetChatlistUnreadCount:[self getUnreadNum:LSUnreadType_Private_Chat]];
                }
            }
        }
    });
}

- (void)manager:(QNContactManager *)manager onSyncRecentContactList:(LSLIVECHAT_LCC_ERR_TYPE)success items:(NSArray *)items errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self.delegates) {
            for (NSValue *value in self.delegates) {
                id<LSUserUnreadCountManagerDelegate> delegate = value.nonretainedObjectValue;
                if ([delegate respondsToSelector:@selector(onGetChatlistUnreadCount:)]) {
                    [delegate onGetChatlistUnreadCount:[self getUnreadNum:LSUnreadType_Private_Chat]];
                }
            }
        }
    });
}


- (NSInteger)getAssignLadyUnreadCount:(NSString * _Nonnull)anchorId {
    NSInteger unreadCount = 0;
    // 更新联系人为有未读消息
    for (LSLadyRecentContactObject *recent in [QNContactManager manager].recentItems) {
        if ([recent.womanId isEqualToString:anchorId]) {
            unreadCount = recent.unreadCount;
            break;
        }
    }
    return unreadCount;
}

@end
