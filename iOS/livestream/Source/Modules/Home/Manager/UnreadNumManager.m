//
//  UnreadNumManager.m
//  livestream
//
//  Created by Randy_Fan on 2018/7/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "UnreadNumManager.h"
#import "LSLoginManager.h"
#import "GetTotalNoreadNumRequest.h"
#import "LSImManager.h"

@interface UnreadNumManager () <LoginManagerDelegate, IMManagerDelegate, IMLiveRoomManagerDelegate>

@property (nonatomic, strong) NSMutableArray *delegates;

// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) TotalUnreadNumObject *unreadModel;

@property (nonatomic, strong) LSImManager *imManager;

@property (nonatomic, assign) BOOL isFirstLogin;

@end

@implementation UnreadNumManager

+ (instancetype)manager {
    static UnreadNumManager *manager = nil;
    if (manager == nil) {
        manager = [[UnreadNumManager alloc] init];
    }
    return manager;
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
        
        self.sessionManager = [LSSessionRequestManager manager];
        
        self.unreadModel = [[TotalUnreadNumObject alloc] init];
        
        self.delegates = [NSMutableArray array];
    }
    return self;
}

- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"UnreadNumManager::onLogin( [IM登录] success : %@, errType : %d, errmsg : %@ )",errType == LCC_ERR_SUCCESS ? @"成功" : @"失败", errType, errmsg);
        if (errType == LCC_ERR_SUCCESS) {
            if (!self.isFirstLogin) {
                [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
                    if (success) {
                        [self delegateToListener:unreadModel];
                    }
                }];
            }
            self.isFirstLogin = NO;
        }
    });
}

- (void)onRecvLoiNotice:(NSString *)anchorId loiId:(NSString *)loiId {
    // TODO:接收意向信通知
    NSLog(@"UnreadNumManager::onRecvLoiNotice( [接收意向信通知] anchorId : %@, loiId : %@ )", anchorId, loiId);
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
    NSLog(@"UnreadNumManager::onRecvEMFNotice( [接收EMF通知] anchorId : %@, emfId : %@ )", anchorId, emfId);
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
    NSLog(@"UnreadNumManager::onRecvBackpackUpdateNotice( [接收背包更新通知] )");
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
    NSLog(@"UnreadNumManager::onRecvProgramPlayNotice( [接收节目开播通知] )");
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
    NSLog(@"UnreadNumManager::onRecvProgramPlayNotice( [接收主播预约私密邀请通知] )");
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
    NSLog(@"UnreadNumManager::onRecvProgramPlayNotice( [接收预约私密邀请回复通知] )");
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
    NSLog(@"UnreadNumManager::onRecvProgramPlayNotice( [接收预约开始倒数通知] )");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getTotalUnreadNum:^(BOOL success, TotalUnreadNumObject *unreadModel) {
            if (success) {
                [self delegateToListener:unreadModel];
            }
        }];
    });
}

- (void)getTotalUnreadNum:(GetTotalNoreadNumHandler)finshHandler {
    GetTotalNoreadNumRequest *request = [[GetTotalNoreadNumRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSMainUnreadNumItemObject * _Nullable userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"UnreadNumManager::GetTotalNoreadNumRequest( [获取主界面未读数量] success : %@, errnum : %d, errmsg : %@, userInfoItem : %@ )",success == YES ? @"成功" : @"失败", errnum, errmsg, userInfoItem);
            if (success) {
                self.unreadModel.ticketNoreadNum = userInfoItem.showTicketUnreadNum;
                self.unreadModel.loiNoreadNum = userInfoItem.loiUnreadNum;
                self.unreadModel.emfNoreadNum = userInfoItem.emfUnreadNum;
                self.unreadModel.messageNoreadNum = userInfoItem.privateMessageUnreadNum;
                self.unreadModel.bookingNoreadNum = userInfoItem.bookingUnreadNum;
                self.unreadModel.backpackNoreadNum = userInfoItem.backpackUnreadNum;
            }
            finshHandler(success, self.unreadModel);
        });
    };
    [self.sessionManager sendRequest:request];
}

// 代理回调
- (void)delegateToListener:(TotalUnreadNumObject *)item {
    @synchronized(self.delegates) {
        for(NSValue* value in self.delegates) {
            id<UnreadNumManagerDelegate> delegate = value.nonretainedObjectValue;
            if ([delegate respondsToSelector:@selector(reloadUnreadView:)]) {
                [delegate reloadUnreadView:item];
            }
        }
    }
}

- (int)getUnreadNum:(UnreadType)type {
    int unreadNum = 0;
    switch (type) {
        case UnreadType_Private_Message:{ // Message
            unreadNum = self.unreadModel.messageNoreadNum;
        }break;
            
        case UnreadType_EMF:{ // Mail
            unreadNum = self.unreadModel.emfNoreadNum;
        }break;
            
        case UnreadType_Loi:{ // Greetings
            unreadNum = self.unreadModel.loiNoreadNum;
        }break;
            
        case UnreadType_Ticket:{ // Ticket
            unreadNum = self.unreadModel.ticketNoreadNum;
        }break;
            
        case UnreadType_Booking:{ // Booking
            unreadNum = self.unreadModel.bookingNoreadNum;
        }break;
            
        default:{ // BackPack
            unreadNum = self.unreadModel.backpackNoreadNum;
        }break;
    }
    return unreadNum;
}

- (void)addDelegate:(id<UnreadNumManagerDelegate>)delegate {
    @synchronized(self) {
        [self.delegates addObject:[NSValue valueWithNonretainedObject:delegate]];
    }
}

- (void)removeDelegate:(id<UnreadNumManagerDelegate>)delegate {
    @synchronized(self) {
        for (NSValue *value in self.delegates) {
            id<UnreadNumManagerDelegate> item = (id<UnreadNumManagerDelegate>)value.nonretainedObjectValue;
            if (item == delegate) {
                [self.delegates removeObject:value];
                break;
            }
        }
    }
}

@end
