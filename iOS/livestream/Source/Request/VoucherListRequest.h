//
//  VoucherListRequest.h
//  dating
//  5.2.获取使用劵列表
//  Created by Alex on 17/8/31
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface VoucherListRequest : SessionRequest

@property (nonatomic, strong) VoucherListFinishHandler _Nullable finishHandler;
@end
