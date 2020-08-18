//
//  GetActivityTimeRequest.h
//  dating
//  17.11.获取服务器当前GMT时间戳
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetActivityTimeRequest : LSSessionRequest
@property (nonatomic, strong) GetActivityTimeFinishHandler _Nullable finishHandler;
@end
