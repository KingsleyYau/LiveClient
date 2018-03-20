//
//  PreRoomInHandler.m
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreRoomInHandler.h"

@implementation PreRoomInHandler

- (void)sendRoomIn:(NSString *)roomid finshHandler:(RoomInHandler)finshHandler {
    [[ZBLSImManager manager] enterRoom:roomid finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ZBImLiveRoomObject * _Nonnull roomItem) {
        NSLog(@"PreInviteToHandler::sendRoomIn( [主播进入指定直播间] success : %@, errType : %d, errMsg : %@)",(success == YES) ? @"成功" : @"失败", errType, errMsg);
        finshHandler(success, errType, errMsg, roomItem);
    }];
}

@end
