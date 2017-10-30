//
//  GetEmoticonListRequest.h
//  dating
//  3.8.获取文本表情列表（用于观众端/主播端获取文本聊天礼物列表）接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetEmoticonListRequest : LSSessionRequest
@property (nonatomic, strong) GetEmoticonListFinishHandler _Nullable finishHandler;
@end
