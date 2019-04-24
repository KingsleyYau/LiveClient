//
//  LSSayHiGetDetailRequest.h
//  dating
//  14.7.获取SayHi详情接口(用于观众端获取SayHi详情)
//  Created by Alex on 19/4/19
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSSayHiGetDetailRequest : LSSessionRequest
/**
 * type     排序（LSSAYHIDETAILTYPE_EARLIEST：Earliest first，LSSAYHIDETAILTYPE_LATEST：Latest First, LSSAYHIDETAILTYPE_UNREAD:Unread first）
 */
@property (nonatomic, assign) LSSayHiDetailType type;
/**
 * sayHiId                         sayHi的ID
 */
@property (nonatomic, copy) NSString* _Nullable sayHiId;

@property (nonatomic, strong) SayHiDetailFinishHandler _Nullable finishHandler;
@end
