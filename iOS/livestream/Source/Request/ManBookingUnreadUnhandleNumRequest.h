//
//  ManBookingUnreadUnhandleNumRequest.h
//  dating
//  4.4.获取预约邀请未读或待处理数量接口
//  Created by Alex on 17/8/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface ManBookingUnreadUnhandleNumRequest : SessionRequest

@property (nonatomic, strong) ManBookingUnreadUnhandleNumFinishHandler _Nullable finishHandler;
@end
