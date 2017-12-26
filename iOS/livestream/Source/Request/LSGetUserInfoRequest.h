//
//  LSGetUserInfoRequest.h
//  dating
//  6.10.获取主播/观众信息
//  Created by Alex on 17/11/01
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetUserInfoRequest : LSSessionRequest

// 观众ID或主播ID
@property (nonatomic, assign) NSString * _Nullable userId;

@property (nonatomic, strong) GetUserInfoFinishHandler _Nullable finishHandler;
@end
