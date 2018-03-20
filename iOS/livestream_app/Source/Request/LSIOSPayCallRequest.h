//
//  LSIOSPayCallRequest.h
//  dating
//  7.3.验证订单信息（仅独立）（仅iOS）接口
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSIOSPayCallRequest : LSSessionRequest
/*
 * @param manid            男士ID
 * @param sid              跨服务器唯一标识
 * @param receipt          AppStore支付成功返回的receipt参数
 * @param orderNo          订单号
 * @param code             AppStore支付完成返回的状态code（APPSTOREPAYTYPE_PAYSUCCES：支付成功，APPSTOREPAYTYPE_PAYFAIL：支付失败，APPSTOREPAYTYPE_PAYRECOVERY：恢复交易(仅非消息及自动续费商品)，APPSTOREPAYTYPE_NOIMMEDIATELYPAY：无法立即支付）（可无，默认：APPSTOREPAYTYPE_PAYSUCCES）
 */
@property (nonatomic, copy) NSString* _Nonnull manid;
@property (nonatomic, copy) NSString* _Nonnull sid;
@property (nonatomic, copy) NSString* _Nonnull receipt;
@property (nonatomic, copy) NSString* _Nonnull orderNo;
@property (nonatomic, assign) AppStorePayCodeType code;
@property (nonatomic, strong) IOSPayCallFinishHandler _Nullable finishHandler;
@end
