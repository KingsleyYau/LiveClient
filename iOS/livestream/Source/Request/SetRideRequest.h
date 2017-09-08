//
//  SetRideRequest.h
//  dating
//  5.4.使用／取消座驾接口
//  Created by Alex on 17/8/31
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface SetRideRequest : SessionRequest
// 座驾ID
@property (nonatomic, copy) NSString *_Nonnull rideId;
@property (nonatomic, strong) SetRideFinishHandler _Nullable finishHandler;
@end
