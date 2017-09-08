//
//  GetAnchorListRequest.h
//  dating
//  3.1.获取Hot列表接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetAnchorListRequest : SessionRequest
// 起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetAnchorListFinishHandler _Nullable finishHandler;
@end
