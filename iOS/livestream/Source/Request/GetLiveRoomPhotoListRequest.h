//
//  GetLiveRoomPhotoListRequest.h
//  dating
//  3.10.获取开播封面图列表（用于主播开播前，获取封面图列表）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomPhotoListRequest : SessionRequest
@property (nonatomic, strong) GetLiveRoomPhotoListFinishHandler _Nullable finishHandler;
@end
