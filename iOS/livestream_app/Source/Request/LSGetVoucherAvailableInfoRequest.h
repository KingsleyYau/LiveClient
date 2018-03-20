//
// LSGetVoucherAvailableInfoRequest.h
//  dating
//  5.6.获取试用券可用信息接口
//  Created by Max on 18/01/24.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetVoucherAvailableInfoRequest : LSSessionRequest
@property (nonatomic, strong) GetVoucherAvailableInfoFinishHandler _Nullable finishHandler;
@end
