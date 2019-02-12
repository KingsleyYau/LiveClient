//
//  LSPremiumMembershipRequest.h
//  dating
//  7.6.获取产品列表（仅iOS）接口
//  Created by Max on 18/9/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSDomainSessionRequest.h"

@interface LSPremiumMembershipRequest : LSDomainSessionRequest

@property (nonatomic, strong) PremiumMembershipFinishHandler _Nullable finishHandler;
@end
