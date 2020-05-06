//
//  LSGetScheduleDurationListRequest.h
//  dating
//  17.1.获取时长价格配置列表
//  Created by Alex on 20/03/31
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetScheduleDurationListRequest : LSSessionRequest

/**
 * 17.1.获取时长价格配置列表接口
 *
 * finishHandler    接口回调
 */
@property (nonatomic, strong) GetScheduleDurationListFinishHandler _Nullable finishHandler;
@end
