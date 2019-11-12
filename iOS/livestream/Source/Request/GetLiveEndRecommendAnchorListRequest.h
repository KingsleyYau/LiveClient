//
//  GetLiveEndRecommendAnchorListRequest.h
//  dating
//  3.15.获取页面推荐的主播列表
//  Created by Alex on 19/6/11
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetLiveEndRecommendAnchorListRequest : LSSessionRequest

@property (nonatomic, strong) GetLiveEndRecommendAnchorListFinishHandler _Nullable finishHandler;
@end
