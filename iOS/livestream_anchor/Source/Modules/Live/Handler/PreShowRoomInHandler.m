//
//  PreShowRoomInHandler.m
//  livestream_anchor
//
//  Created by test on 2018/4/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreShowRoomInHandler.h"

@implementation PreShowRoomInHandler

- (void)getShowRoomInfo:(NSString * _Nonnull)liveShowId finshHandler:(ShowRoomInHandler _Nonnull)finshHandler {
    
    [[LSAnchorRequestManager manager] anchorGetShowRoomInfo:liveShowId finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSAnchorProgramItemObject * _Nullable item, NSString * _Nonnull roomId) {
        NSLog(@"PreShowRoomInHandler::getShowRoomInfo( [主播获取房间信息] success : %@, errnum : %d, errmsg : %@)",(success == YES) ? @"成功" : @"失败", errnum, errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            finshHandler(success, item, roomId, errnum, errmsg);
        });
    }];

}
@end
