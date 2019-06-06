//
//  LSGetLoiListRequest.h
//  dating
//  13.1.获取意向信列表
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetLoiListRequest : LSSessionRequest
// tag类型（LSLETTERTAG_ALL：所有，LSLETTERTAG_UNREAD：未读，LSLETTERTAG_UNREPLIED：未回复，LSLETTERTAG_REPLIED：已回复，LSLETTERTAG_FOLLOW：已Follow）
@property (nonatomic, assign) LSLetterTag tag;
// 起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetLoiListFinishHandler _Nullable finishHandler;
@end
