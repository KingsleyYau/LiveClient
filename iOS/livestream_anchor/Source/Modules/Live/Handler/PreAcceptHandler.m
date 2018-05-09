//
//  PreAcceptHandler.m
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreAcceptHandler.h"

@implementation PreAcceptHandler

- (void)acceptInviteWithId:(NSString *)inviteid finshHandler:(AcceptInvitedHandler)finshHandler {
    [[LSAnchorRequestManager manager] anchorAcceptInstanceInvite:inviteid finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, ZBHttpRoomType roomType) {
        NSLog(@"PreAcceptHandler::acceptInviteWithId:( [主播接收立即私密邀请] success : %@, errnum : %d, errmsg : %@, roomid : %@, roomType : %d)",(success == YES) ? @"成功":@"失败", errnum, errmsg, roomId, roomType);
        dispatch_async(dispatch_get_main_queue(), ^{
           finshHandler(success, errnum, errmsg, roomId, roomType);
        });
    }];
}

@end
