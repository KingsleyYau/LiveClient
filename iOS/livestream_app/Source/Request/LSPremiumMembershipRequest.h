//
//  LSPremiumMembershipRequest.h
//  dating
//  7.1.获取买点信息（仅独立）接口
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSPremiumMembershipRequest : LSSessionRequest
/*
 * @param siteId           站点ID
 */
@property (nonatomic, copy) NSString* _Nonnull siteId;
@property (nonatomic, strong) PremiumMembershipFinishHandler _Nullable finishHandler;
@end
