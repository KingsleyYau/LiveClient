//
//  LSGetEmfDetailRequest.h
//  dating
//   13.4.获取信件详情
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetEmfDetailRequest : LSSessionRequest
// 意向信Id
@property (nonatomic, copy) NSString* _Nullable emfId;
@property (nonatomic, strong) GetEmfDetailFinishHandler _Nullable finishHandler;
@end
