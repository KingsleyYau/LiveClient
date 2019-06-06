//
// LSDealKnockRequest.h
//  dating
//  8.5.同意主播敲门请求
//  Created by Max on 18/04/13.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSDealKnockRequest : LSSessionRequest
/**
 *  8.5.同意主播敲门请求接口
 *
 *  knockId          敲门ID
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, copy) NSString * _Nullable knockId;
@property (nonatomic, strong) DealKnockRequestFinishHandler _Nullable finishHandler;
@end
