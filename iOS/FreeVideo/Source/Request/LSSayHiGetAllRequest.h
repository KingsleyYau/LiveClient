//
//  LSSayHiGetAllRequest.h
//  dating
//  14.5.获取Say Hi的All列表接口（用于观众端获取Say Hi的All列表数据）
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiGetAllRequest : LSSessionRequest
/**
 * start    起始，用于分页，表示从第几个元素开始获取
 */
@property (nonatomic, assign) int start;
/**
 * step     步长，用于分页，表示本次请求获取多少个元素
 */
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetAllSayHiListFinishHandler _Nullable finishHandler;
@end
