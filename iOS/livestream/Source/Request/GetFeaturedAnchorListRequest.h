//
//  GetFeaturedAnchorListRequesth
//  dating
//  3.18.Featured欄目的推荐主播列表接口
//  Created by Max on 19/11/12.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetFeaturedAnchorListRequest : LSSessionRequest
// 起始，用于分页，表示从第几个元素开始获取
@property (nonatomic, assign) int start;
// 步长，用于分页，表示本次请求获取多少个元素
@property (nonatomic, assign) int step;
@property (nonatomic, strong) GetFeaturedAnchorListFinishHandler _Nullable finishHandler;
@end
