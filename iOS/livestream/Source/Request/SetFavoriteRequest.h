//
//  SetFavoriteRequest.h
//  dating
//  6.3.添加／取消收藏接口
//  Created by Alex on 17/8/31
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface SetFavoriteRequest : SessionRequest
// 主播ID
@property (nonatomic, copy) NSString * _Nonnull userId;
// 直播间ID（可无，无则表示不在直播间操作）
@property (nonatomic, copy) NSString * _Nonnull roomId;
// 是否收藏（0:否 1:是）
@property (nonatomic, assign) BOOL isFav;
@property (nonatomic, strong) SetFavoriteFinishHandler _Nullable finishHandler;
@end
