//
//  VoucherListRequest.h
//  dating
//  5.3.获取座驾列表接口
//  Created by Alex on 17/8/31
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface RideListRequest : SessionRequest

@property (nonatomic, strong) RideListFinishHandler _Nullable finishHandler;
@end
