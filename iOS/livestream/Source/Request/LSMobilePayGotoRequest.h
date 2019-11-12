//
//  LSMobilePayGotoRequest.h
//  dating
//  7.7.获取h5买点页面URL
//  Created by Alex on 19/10/16
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSMobilePayGotoRequest : LSSessionRequest

/**
 * 7.7.获取h5买点页面URL接口
 *
 *  orderType    购买产品类型（LSORDERTYPE_CREDIT：信用点，LSORDERTYPE_FLOWERGIFT：鲜花礼品, LSORDERTYPE_MONTHFEE：月费服务，LSORDERTYPE_STAMP：邮票）
 *  clickFrom    点击来源（Axx表示不可切换，Bxx表示可切换）（可""，""则表示不指定）
 *  number       已选中的充值包ID（可""，""表示不指定充值包）
 *  orderNo      鲜花礼品订单ID（可无，无或空表示无订单ID）
 * finishHandler    回调
 */
@property (nonatomic, assign) LSOrderType orderType;
@property (nonatomic, copy) NSString* _Nullable clickFrom;
@property (nonatomic, copy) NSString* _Nullable number;
@property (nonatomic, copy) NSString* _Nullable orderNo;
@property (nonatomic, strong) MobilePayGotoFinishHandler _Nullable finishHandler;
@end
