//
//  GetPromoAnchorListRequest.h
//  dating
//  3.14.获取推荐主播列表
//  Created by Alex on 17/9/05
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetPromoAnchorListRequest : SessionRequest
// 获取推荐个数
@property (nonatomic, assign) int number;
@property (nonatomic, strong) GetPromoAnchorListFinishHandler _Nullable finishHandler;
@end
