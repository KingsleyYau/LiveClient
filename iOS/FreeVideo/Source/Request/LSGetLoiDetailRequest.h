//
//  LSGetLoiDetailRequest.h
//  dating
//   13.2.获取意向信详情
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetLoiDetailRequest : LSSessionRequest
// 意向信Id
@property (nonatomic, copy) NSString* _Nullable loiId;
@property (nonatomic, strong) GetLoiDetailFinishHandler _Nullable finishHandler;
@end
