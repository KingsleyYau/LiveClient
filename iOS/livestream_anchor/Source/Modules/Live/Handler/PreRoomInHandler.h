//
//  PreRoomInHandler.h
//  livestream_anchor
//
//  Created by randy on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBLSRequestManager.h"
#import "ZBLSImManager.h"

@interface PreRoomInHandler : NSObject

typedef void (^RoomInHandler)(BOOL success, ZBLCC_ERR_TYPE errnum, NSString *errmsg, ZBImLiveRoomObject *item);

/**
 3.2 主播进入指定直播间
 
 @param roomid 直播间id
 @param finshHandler 结束回调
 */
- (void)sendRoomIn:(NSString *)roomid finshHandler:(RoomInHandler)finshHandler;

@end
