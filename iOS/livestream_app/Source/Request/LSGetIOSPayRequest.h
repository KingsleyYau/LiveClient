//
//  LSGetIOSPayRequest.h
//  dating
//  7.2.获取订单信息（仅独立）（仅iOS）接口
//  Created by Max on 17/12/23.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetIOSPayRequest : LSSessionRequest
/*
 *  @param  manid            男士ID
 *   @param sid              跨服务器唯一标识
 *   @param number           信用点套餐ID
 *   @param siteid           站点ID
 */
@property (nonatomic, copy) NSString* _Nonnull manid;
@property (nonatomic, copy) NSString* _Nonnull sid;
@property (nonatomic, copy) NSString* _Nonnull number;
@property (nonatomic, copy) NSString* _Nonnull siteid;
@property (nonatomic, strong) GetIOSPayFinishHandler _Nullable finishHandler;
@end
