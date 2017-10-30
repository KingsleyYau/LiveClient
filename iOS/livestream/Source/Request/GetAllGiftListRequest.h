//
//  GetAllGiftListRequest.h
//  dating
//  3.5.获取礼物列表(观众端／主播端获取礼物列表，登录成功即获取礼物列表)接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetAllGiftListRequest : LSSessionRequest
@property (nonatomic, strong) GetAllGiftListFinishHandler _Nullable finishHandler;
@end
