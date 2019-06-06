//
// LSGetShowRoomInfoRequest.h
//  dating
//  9.5.获取可进入的节目信息
//  Created by Max on 18/04/23.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetShowRoomInfoRequest : LSSessionRequest
/**
 *  9.3.购买节目接口
 *
 *  liveShowId       节目ID
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable liveShowId;
@property (nonatomic, strong) GetShowRoomInfoFinishHandler _Nullable finishHandler;
@end
