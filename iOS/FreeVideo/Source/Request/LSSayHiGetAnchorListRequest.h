//
//  LSSayHiGetAnchorListRequest.h
//  dating
//  14.2.获取可发Say Hi的主播列表（用于Say Hi的All列表没有数据时，观众获取可发Say Hi的主播列表）
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiGetAnchorListRequest : LSSessionRequest
@property (nonatomic, strong) GetSayHiAnchorListFinishHandler _Nullable finishHandler;
@end
