//
//  GetConfigRequest.h
//  dating
//  6.1.同步配置接口
//  Created by Alex on 17/8/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetConfigRequest : SessionRequest

@property (nonatomic, strong) GetConfigFinishHandler _Nullable finishHandler;
@end
