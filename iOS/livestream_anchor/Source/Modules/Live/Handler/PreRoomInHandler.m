//
//  PreRoomInHandler.m
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreRoomInHandler.h"

@implementation PreRoomInHandler

- (BOOL)sendRoomIn:(NSString *)roomid finshHandler:(RoomInHandler)finshHandler {
   BOOL bFlag = [[LSAnchorImManager manager] enterRoom:roomid finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString * _Nonnull errMsg, ZBImLiveRoomObject * _Nonnull roomItem) {
        NSLog(@"PreRoomInHandler::sendRoomIn( [主播进入指定直播间] success : %@, errType : %d, errMsg : %@)",(success == YES) ? @"成功" : @"失败", errType, errMsg);
        dispatch_async(dispatch_get_main_queue(), ^{
           finshHandler(success, errType, errMsg, roomItem);
        });
    }];
    return bFlag;
}

@end
