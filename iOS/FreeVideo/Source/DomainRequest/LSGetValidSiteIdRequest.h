//
//  LSGetValidSiteIdRequest.h
//  dating
//  2.13.可登录的站点列表
//  Created by Alex on 18/6/22
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSDomainSessionRequest.h"

/**
 *  2.13.可登录的站点列表接口
 *
 *  email            用户的email或id
 *  password         登录密码
 *  finishHandler    接口回调

 */
@interface LSGetValidSiteIdRequest : LSDomainSessionRequest
@property (nonatomic, copy) NSString * _Nonnull email;
@property (nonatomic, copy) NSString * _Nonnull password;
@property (nonatomic, strong) GetValidsiteIdFinishHandler _Nullable finishHandler;
@end
