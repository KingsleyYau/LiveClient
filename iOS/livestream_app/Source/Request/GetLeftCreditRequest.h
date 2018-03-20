//
//  GetLeftCreditRequest.h
//  dating
//  6.2.获取账号余额接口
//  Created by Alex on 17/8/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetLeftCreditRequest : LSSessionRequest

@property (nonatomic, strong) GetLeftCreditFinishHandler _Nullable finishHandler;
@end
