//
//  LSGetMyProfileRequest.h
//  dating
//  6.18.查询个人信息
//  Created by Alex on 18/6/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  6.18.查询个人信息接口
 *

 *  finishHandler    接口回调

 */
@interface LSGetMyProfileRequest : LSSessionRequest
@property (nonatomic, strong) GetMyProfileFinishHandler _Nullable finishHandler;
@end
