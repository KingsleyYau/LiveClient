//
//  LSChangePasswordRequest.h
//  dating
//  2.17.修改密码
//  Created by Alex on 18/9/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  22.17.修改密码接口
 *
 *  passwordNew           新密码
 *  passwordOld           旧密码
 *  finishHandler    接口回调

 */
@interface LSChangePasswordRequest : LSSessionRequest
@property (nonatomic, copy) NSString * _Nullable passwordNew;
@property (nonatomic, copy) NSString * _Nullable passwordOld;
@property (nonatomic, strong) ChangePasswordFinishHandler _Nullable finishHandler;
@end
