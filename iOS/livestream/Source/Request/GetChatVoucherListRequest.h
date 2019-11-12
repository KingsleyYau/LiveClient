//
//  GetChatVoucherListRequest.h
//  dating
//  5.7.获取LiveChat聊天试用券列表
//  Created by Alex on 19/6/11
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetChatVoucherListRequest : LSSessionRequest

@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetChatVoucherListFinishHandler _Nullable finishHandler;
@end
