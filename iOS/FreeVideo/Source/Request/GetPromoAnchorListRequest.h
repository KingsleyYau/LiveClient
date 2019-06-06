//
//  GetPromoAnchorListRequest.h
//  dating
//  3.14.获取推荐主播列表
//  Created by Alex on 17/9/05
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetPromoAnchorListRequest : LSSessionRequest
// 获取推荐个数
@property (nonatomic, assign) int number;
// 获取界面的类型（1:直播间 2:主播个人页）
@property (nonatomic, assign) PromoAnchorType type;
// 当前界面的主播ID，返回结果将不包含当前主播（可无， 无则表示不过滤结果）
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, strong) GetPromoAnchorListFinishHandler _Nullable finishHandler;
@end
