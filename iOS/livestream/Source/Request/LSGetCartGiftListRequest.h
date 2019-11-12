//
//  LSGetCartGiftListRequest.h
//  dating
//  15.7.获取购物车My cart列表
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetCartGiftListRequest : LSSessionRequest

/**
 * 15.7.获取购物车My cart列表接口
 *
 * start                         起始，用于分页，表示从第几个元素开始获取
 * step                          步长，用于分页，表示本次请求获取多少个元素
 * finishHandler    接口回调
 */
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetCartGiftListFinishHandler _Nullable finishHandler;
@end
