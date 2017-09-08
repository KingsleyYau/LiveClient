//
//  ManHandleBookingListRequest.h
//  dating
//  4.1.观众待处理的预约邀请列表接口
//  Created by Alex on 17/8/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface ManHandleBookingListRequest : SessionRequest

// 列表类型（0:等待观众处理 1:等待主播处理 2:已确认 3：历史）
@property (nonatomic, assign) BookingListType type;
//  起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) ManHandleBookingListFinishHandler _Nullable finishHandler;
@end
