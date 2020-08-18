//
//  LSRecommendPremiumVideoListRequest.h
//  dating
//  18.11.获取可能感兴趣的推荐视频列表
//  Created by Alex on 20/08/04
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSRecommendPremiumVideoListRequest : LSSessionRequest

//  推荐数量
@property (nonatomic, assign) int num;
@property (nonatomic, strong) RecommendPremiumVideoListFinishHandler _Nullable finishHandler;
@end
