//
//  GetFollowListRequest.h
//  dating
//  3.2.获取Following列表接口
//  Created by Alex on 17/8/17.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetFollowListRequest : SessionRequest
 // 起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetFollowListFinishHandler _Nullable finishHandler;
@end
