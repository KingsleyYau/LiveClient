//
//  LSSayHiGetResponseRequest.h
//  dating
//  14.6.获取SayHi的Response列表接口(用于观众端获取Say Hi的Response列表)
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiGetResponseRequest : LSSessionRequest
/**
 * type     排序（LSSAYHIDETAILTYPE_EARLIEST：Unread First，LSSAYHIDETAILTYPE_LATEST：Latest First）
 */
@property (nonatomic, assign) LSSayHiListType type;
/**
 * start    起始，用于分页，表示从第几个元素开始获取
 */
@property (nonatomic, assign) int start;
/**
 * step     步长，用于分页，表示本次请求获取多少个元素
 */
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetResponseSayHiListFinishHandler _Nullable finishHandler;
@end
