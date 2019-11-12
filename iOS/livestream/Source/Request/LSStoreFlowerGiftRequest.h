//
//  LSStoreFlowerGiftRequest.h
//  dating
//  15.1.获取鲜花礼品列表
//  Created by Alex on 19/09/29
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSStoreFlowerGiftRequest : LSSessionRequest

/**
 * 15.1.获取鲜花礼品列表接口
 *
 * anchorId         主播ID（可无）
 * finishHandler    接口回调
 */
@property (nonatomic, copy) NSString* _Nullable anchorId;
@property (nonatomic, strong) GetStoreGiftListFinishHandler _Nullable finishHandler;
@end
