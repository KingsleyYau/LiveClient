//
// LSGetHangoutGiftListRequest.h
//  dating
//  8.6.获取多人互动直播间可发送的礼物列表
//  Created by Max on 18/04/13.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetHangoutGiftListRequest : LSSessionRequest
/**
 *  8.6.获取多人互动直播间可发送的礼物列表接口
 *
 *  roomId          直播间ID
 *  finishHandler   接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable roomId;
@property (nonatomic, strong) GetHangoutGiftListFinishHandler _Nullable finishHandler;
@end
