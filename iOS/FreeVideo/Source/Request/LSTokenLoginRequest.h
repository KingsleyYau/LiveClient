//
//  LSTokenLoginRequest.h
//  dating
//  2.21.token登录
//  Created by Alex on 18/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  2.21.token登录接口
 *
 * memberId          用户id
 * otherToken        用于登录其他站点的加密串，即其它站点获取的token
 *  finishHandler    接口回调

 */
@interface LSTokenLoginRequest : LSSessionRequest
@property (nonatomic, copy) NSString * _Nullable memberId;
@property (nonatomic, copy) NSString * _Nullable otherToken;
@property (nonatomic, strong) LoginWithTokenFinishHandler _Nullable finishHandler;
@end
