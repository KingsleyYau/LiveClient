//
//  LSGetRecommendGiftListRequest.h
//  dating
//  15.3.获取推荐鲜花礼品列表
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetRecommendGiftListRequest : LSSessionRequest

/**
 * 15.3.获取推荐鲜花礼品列表接口
 *
 * giftId           礼物ID
 * anchorId         主播ID
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable giftId;
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, assign) int number;
@property (nonatomic, strong) GetRecommendGiftListFinishHandler _Nullable finishHandler;
@end
