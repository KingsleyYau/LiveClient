//
//  LSSayHiConfigRequest.h
//  dating
//  14.1.获取发送SayHi的主题和文本信息（用于观众端获取发送SayHi的主题和文本信息）
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiConfigRequest : LSSessionRequest
@property (nonatomic, strong) SayHiConfigFinishHandler _Nullable finishHandler;
@end
