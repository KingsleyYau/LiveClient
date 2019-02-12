//
//  LSDestroyTokenRequest.h
//  dating
//  2.15.销毁App token
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSDomainSessionRequest.h"

/**
 *  2.15.销毁App token接口
 *
 *  finishHandler    接口回调

 */
@interface LSDestroyTokenRequest : LSDomainSessionRequest
@property (nonatomic, strong) DestroyTokenFinishHandler _Nullable finishHandler;
@end
