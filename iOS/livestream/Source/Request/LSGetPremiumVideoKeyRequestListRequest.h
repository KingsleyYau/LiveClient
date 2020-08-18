//
//  LSGetPremiumVideoKeyRequestListRequest.h
//  dating
//  18.3.获取解码锁请求列表
//  Created by Alex on 20/08/04
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetPremiumVideoKeyRequestListRequest : LSSessionRequest

//解码锁回复类型（LSACCESSKEYTYPES_REPLY ： 已回复， LSACCESSKEYTYPE_UNREPLY：未回复）
@property (nonatomic, assign) LSAccessKeyType type;
//  起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetPremiumVideoKeyRequestListinishHandler _Nullable finishHandler;
@end
