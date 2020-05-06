//
//  LSGetCountryTimeZoneListRequest.h
//  dating
//  17.2.获取国家时区列表
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetCountryTimeZoneListRequest : LSSessionRequest

/**
 * 17.2.获取国家时区列表接口
 *
 * finishHandler    接口回调
 */
@property (nonatomic, strong) GetCountryTimeZoneListFinishHandler _Nullable finishHandler;
@end
