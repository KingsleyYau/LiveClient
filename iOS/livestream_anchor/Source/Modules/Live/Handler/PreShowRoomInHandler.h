//
//  PreShowRoomInHandler.h
//  livestream_anchor
//
//  Created by test on 2018/4/27.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreRoomInHandler.h"

@interface PreShowRoomInHandler : PreRoomInHandler

typedef void (^ShowRoomInHandler)(BOOL success, LSAnchorProgramItemObject * _Nonnull item, NSString * _Nonnull roomId, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg);
/**
 7.3.获取可进入的节目信息接口
 
 @param liveShowId 邀请liveShowId
 @param finshHandler 请求回调
 */
- (void)getShowRoomInfo:(NSString * _Nonnull)liveShowId finshHandler:(ShowRoomInHandler _Nonnull)finshHandler;
@end
