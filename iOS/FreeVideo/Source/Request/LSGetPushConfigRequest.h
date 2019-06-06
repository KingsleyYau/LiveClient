//
//  LSGetPushConfigRequest.h
//  dating
//  11.1.获取推送设置
//  Created by Alex on 18/9/28
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetPushConfigRequest : LSSessionRequest

@property (nonatomic, strong) GetPushConfigFinishHandler _Nullable finishHandler;
@end
