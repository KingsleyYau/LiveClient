//
//  GiftListRequest.h
//  dating
//  5.1.获取背包礼物列表接口
//  Created by Alex on 17/8/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GiftListRequest : SessionRequest

@property (nonatomic, strong) GiftListFinishHandler _Nullable finishHandler;
@end
