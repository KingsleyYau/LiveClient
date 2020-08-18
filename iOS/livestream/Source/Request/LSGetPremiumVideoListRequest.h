//
//  LSGetPremiumVideoListRequest.h
//  dating
//  18.2.获取付费视频列表
//  Created by Alex on 20/08/03
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetPremiumVideoListRequest : LSSessionRequest

//分类ID（多个用’,’号分隔）(传空就是全部)
@property (nonatomic, copy) NSString* _Nonnull typeIds;
//  起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetPremiumVideoListFinishHandler _Nullable finishHandler;
@end
