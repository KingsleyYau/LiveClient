//
//  GetBackpackUnreadNumRequest.h
//  dating
//  5.5.获取背包未读数量接口
//  Created by Alex on 17/8/31
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetBackpackUnreadNumRequest : LSSessionRequest
@property (nonatomic, strong) GetBackpackUnreadNumFinishHandler _Nullable finishHandler;
@end
