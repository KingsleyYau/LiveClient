//
//  GetCreateBookingInfoRequest.h
//  dating
//  4.5.获取新建预约邀请信息
//  Created by Alex on 17/8/31
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetCreateBookingInfoRequest : SessionRequest
// 主播ID
@property (nonatomic, copy) NSString * _Nullable  userId;
@property (nonatomic, strong) GetCreateBookingInfoFinishHandler _Nullable finishHandler;
@end
