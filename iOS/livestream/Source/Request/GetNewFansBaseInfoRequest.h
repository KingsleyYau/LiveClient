//
//  GetNewFansBaseInfoRequest.h
//  dating
//  3.12.获取指定观众信息接口
//  Created by Alex on 17/8/30
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetNewFansBaseInfoRequest : LSSessionRequest
// 观众ID
@property (nonatomic, copy) NSString * _Nullable  userId;
@property (nonatomic, strong) GetNewFansBaseInfoFinishHandler _Nullable finishHandler;
@end
