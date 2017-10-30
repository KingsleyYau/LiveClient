//
//  HandleBookingRequest.h
//  dating
//  4.2.观众处理预约邀请接口
//  Created by Alex on 17/8/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface HandleBookingRequest : LSSessionRequest

// 邀请ID
@property (nonatomic, copy) NSString* _Nonnull inviteId;
// 是否同意（0:否 1:是）
@property (nonatomic, assign) BOOL isConfirm;
@property (nonatomic, strong) HandleBookingFinishHandler _Nullable finishHandler;
@end
