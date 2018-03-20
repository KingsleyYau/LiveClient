//
//  SendBookingRequest.h
//  dating
//  4.6.新建预约邀请
//  Created by Alex on 17/8/31
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface SendBookingRequest : LSSessionRequest
// 主播ID
@property (nonatomic, copy) NSString * _Nullable  userId;
// 预约时间ID
@property (nonatomic, copy) NSString * _Nullable  timeId;
// 预约时间
@property (nonatomic, assign) NSInteger bookTime;
// 礼物ID
@property (nonatomic, copy) NSString * _Nullable giftId;
// 礼物数量
@property (nonatomic, assign) int giftNum;
// 是否需要短信通知
@property (nonatomic, assign) BOOL needSms;
@property (nonatomic, strong) SendBookingRequestFinishHandler _Nullable finishHandler;
@end
