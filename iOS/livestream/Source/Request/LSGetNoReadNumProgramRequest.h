//
// LSGetNoReadNumProgramRequest.h
//  dating
//  9.1.获取节目列表未读
//  Created by Max on 18/04/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetNoReadNumProgramRequest : LSSessionRequest
/**
 *  9.1.获取节目列表未读接口
 *
 *  finishHandler    接口回调
 *
 */
@property (nonatomic, strong) GetNoReadNumProgramFinishHandler _Nullable finishHandler;
@end
