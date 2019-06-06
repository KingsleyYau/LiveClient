//
//  LSGetTokenRequest.h
//  dating
//  2.19.获取认证token
//  Created by Alex on 18/9/25
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

/**
 *  2.19.获取认证token接口
 *
 * siteId            站点ID
 *  finishHandler    接口回调

 */
@interface LSGetTokenRequest : LSSessionRequest
@property (nonatomic, assign) HTTP_OTHER_SITE_TYPE siteId;
@property (nonatomic, strong) GetTokenFinishHandler _Nullable finishHandler;
@end
