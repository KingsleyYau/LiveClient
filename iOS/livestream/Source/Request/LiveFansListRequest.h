//
//  LiveFansListRequest.h
//  dating
//  3.4.获取直播间观众头像列表接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LiveFansListRequest : LSSessionRequest
/**
 * roomId                        直播间ID
 * start                         起始，用于分页，表示从第几个元素开始获取
 * step                          步长，用于分页，表示本次请求获取多少个元素 */

@property (nonatomic, copy) NSString * _Nullable roomId;
@property (nonatomic, assign)int start;
@property (nonatomic, assign)int step;
@property (nonatomic, strong) LiveFansListFinishHandler _Nullable finishHandler;
@end
