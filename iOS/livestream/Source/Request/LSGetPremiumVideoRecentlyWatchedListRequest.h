//
//  LSGetPremiumVideoRecentlyWatchedListRequest.h
//  dating
//  18.6.获取最近播放的视频列表
//  Created by Alex on 20/08/05
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetPremiumVideoRecentlyWatchedListRequest : LSSessionRequest

//  起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetPremiumVideoRecentlyWatchedListFinishHandler _Nullable finishHandler;
@end
