//
// LSBuyProgramRequest.h
//  dating
//  9.4.购买
//  Created by Max on 18/04/13.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSBuyProgramRequest : LSSessionRequest
/**
 *  9.3.购买节目接口
 *
 *  liveShowId       节目ID
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable liveShowId;
@property (nonatomic, strong) BuyProgramFinishHandler _Nullable finishHandler;
@end
