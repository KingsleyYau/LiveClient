//
//  LSGetManBaseInfoRequest.h
//  dating
//  6.14.获取个人信息（仅独立）接口
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetManBaseInfoRequest : LSSessionRequest
@property (nonatomic, strong) GetManBaseInfoFinishHandler _Nullable finishHandler;
@end
