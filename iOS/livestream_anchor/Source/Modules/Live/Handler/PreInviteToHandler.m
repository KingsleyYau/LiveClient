//
//  PreInviteToHandler.m
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreInviteToHandler.h"
#import "LSTimer.h"

@interface PreInviteToHandler()<ZBIMManagerDelegate, ZBIMLiveRoomManagerDelegate>
@property (strong) LSTimer *inviteTimer;

@property (nonatomic, assign) BOOL isInviteReply;
@end

@implementation PreInviteToHandler

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [[ZBLSImManager manager] addDelegate:self];
        [[ZBLSImManager manager].client addDelegate:self];
        
        self.inviteTimer = [[LSTimer alloc] init];
        self.isInviteReply = NO;
    }
    return self;
}

#pragma mark - 网络请求
- (void)instantInviteWithUserid:(NSString *)userid finshHandler:(InvitedHandler)finshHandler {
    [[ZBLSImManager manager] anchorSendImmediatePrivateInvite:userid finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, NSString * _Nonnull invitation, int timeOut, NSString * _Nonnull roomId) {
        NSLog(@"PreInviteToHandler::instantInviteWithUserid( [主播发送立即私密邀请] success : %@, errType : %d, errMsg : %@, invitation : %@, timeOut : %d, roomId : %@ )",(success == YES) ? @"成功" : @"失败", errType, errMsg, invitation, timeOut, roomId);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.inviteid = invitation;
                
                // 发送私密邀请超时倒计时
                if (timeOut) {
                    WeakObject(self, weakSelf);
                    [self.inviteTimer startTimer:nil timeInterval:timeOut * NSEC_PER_SEC starNow:NO action:^{
                        if ([weakSelf.inviteDelegate respondsToSelector:@selector(inviteIsTimeOut)]) {
                            [weakSelf.inviteDelegate inviteIsTimeOut];
                        }
                    }];
                }
            }
            finshHandler(success, errType, errMsg, invitation, roomId);
        });
    }];
}


- (void)cancelInviteWithId:(NSString *)inviteid finshHandler:(CancelInvitedHandler)finshHandler {
    [[ZBLSRequestManager manager] anchorCancelInstantInvite:inviteid finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"PreInviteToHandler::cancelInviteWithId( [主播取消已发送立即私密邀请] success : %@, errnum : %d, errmsg : %@)",(success == YES) ? @"成功" : @"失败", errnum, errmsg);
        finshHandler(success, errnum, errmsg);
    }];
}

- (void)sendRoomIn:(NSString *)roomid finshHandler:(RoomInHandler)finshHandler {
    [[ZBLSImManager manager] enterRoom:roomid finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ZBImLiveRoomObject * _Nonnull roomItem) {
        NSLog(@"PreInviteToHandler::sendRoomIn( [主播进入指定直播间] success : %@, errType : %d, errMsg : %@)",(success == YES) ? @"成功" : @"失败", errType, errMsg);
        finshHandler(success, errType, errMsg, roomItem);
    }];
}

#pragma mark - IM回调
- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ZBImLoginReturnObject *)item {
    NSLog(@"PreInviteToHandler::onZBLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == ZBLCC_ERR_SUCCESS && !self.isInviteReply) {
            // IM断线查询指定私密邀请信息
            if (self.inviteid) {
                [[ZBLSImManager manager] anchorGetInviteInfo:self.inviteid finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ZBImInviteIdItemObject * _Nonnull item) {
                    NSLog(@"PreInviteToHandler::anchorGetInviteInfo( [获取指定立即私密邀请信息] success : %@, errType : %d, errMsg : %@)", (success == YES) ? @"成功" : @"失败", errType, errMsg);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            if ([self.inviteDelegate respondsToSelector:@selector(getInviteInfoWithId:imInviteIdItem:)]) {
                                [self.inviteDelegate getInviteInfoWithId:self.inviteid imInviteIdItem:item];
                            }
                        }
                    });
                }];
            }
        }
    });
}

- (void)onZBLogout:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"PreInviteToHandler::onZBLogout( [IM注销通知], errType : %d, errmsg : %@ )", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)onZBRecvInstantInviteReplyNotice:(NSString *)inviteId replyType:(ZBReplyType)replyType roomId:(NSString *)roomId roomType:(ZBRoomType)roomType userId:(NSString *)userId nickName:(NSString *)nickName avatarImg:(NSString *)avatarImg {
    NSLog(@"PreInviteToHandler::onZBRecvInstantInviteReplyNotice( [接收立即私密邀请回复通知] inviteid : %@, replyType : %d, roomid : %@, roomType : %d, userid : %@, nickName : %@, avatarImg : %@ )", inviteId, replyType, roomId, roomType, userId, nickName, avatarImg);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isInviteReply = YES;
        
        // 定时私密邀请倒计时
        [self.inviteTimer stopTimer];
        
        InstantInviteItem *item = [[InstantInviteItem alloc] init];
        item.inviteId = inviteId;
        item.replyType = replyType;
        item.roomId = roomId;
        item.roomType = roomType;
        item.userId = userId;
        item.nickName = nickName;
        item.avatarImg = avatarImg;
        if ([self.inviteDelegate respondsToSelector:@selector(instantInviteReply:)]) {
            [self.inviteDelegate instantInviteReply:item];
        }
    });
}


@end
