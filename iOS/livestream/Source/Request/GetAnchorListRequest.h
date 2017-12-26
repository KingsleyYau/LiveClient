//
//  GetAnchorListRequest.h
//  dating
//  3.1.获取Hot列表接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetAnchorListRequest : LSSessionRequest
// 起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
// 是否只获取观众看过的主播（0: 否 1: 是  可无，无则默认为0）
@property (nonatomic, assign) BOOL hasWatch;
// 是否可看到测试主播（0：否，1：是）（整型）（可无，无则默认为0）
@property (nonatomic, assign) BOOL isForTest;
@property (nonatomic, strong) GetAnchorListFinishHandler _Nullable finishHandler;
@end
