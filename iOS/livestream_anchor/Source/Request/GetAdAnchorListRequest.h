//
//  GetAdAnchorListRequest.h
//  dating
//  6.4.获取QN广告列表
//  Created by Alex on 17/9/15
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetAdAnchorListRequest : LSSessionRequest
// 客户段需要获取的数量
@property (nonatomic, assign) int number;
@property (nonatomic, strong) GetAdAnchorListFinishHandler _Nullable finishHandler;
@end
