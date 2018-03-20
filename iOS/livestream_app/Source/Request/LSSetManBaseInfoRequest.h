//
// LSSetManBaseInfoRequest.h
//  dating
//  6.15.设置个人信息（仅独立）接口
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSetManBaseInfoRequest : LSSessionRequest
// 昵称
@property (nonatomic, copy) NSString* _Nonnull nickName;
@property (nonatomic, strong) SetManBaseInfoFinishHandler _Nullable finishHandler;
@end
