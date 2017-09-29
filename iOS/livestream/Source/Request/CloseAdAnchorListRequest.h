//
//  CloseAdAnchorListRequest.h
//  dating
//  6.5.关闭QN广告列表
//  Created by Alex on 17/9/15
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface CloseAdAnchorListRequest : SessionRequest

@property (nonatomic, strong) CloseAdAnchorListFinishHandler _Nullable finishHandler;
@end
