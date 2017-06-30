//
//  GetLiveRoomConfigRequest.h
//  dating
//  5.1.同步配置（用于客户端获取http接口服务器，IM服务器及上传图片服务器域名及端口等配置）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomConfigRequest : SessionRequest
@property (nonatomic, strong) GetLiveRoomConfigFinishHandler _Nullable finishHandler;
@end
