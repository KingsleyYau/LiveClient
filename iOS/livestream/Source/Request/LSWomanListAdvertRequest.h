//
//  LSWomanListAdvertRequest.h
//  dating
//  6.25.查询女士列表广告
//  Created by Alex on 19/10/09
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSWomanListAdvertRequest : LSSessionRequest

/**
 * 6.25.获取直播主播列表广告接口
 *
 *  finishHandler    回调
 * finishHandler    接口回调
 */

@property (nonatomic, strong) WonmanListAdvertFinishHandler _Nullable finishHandler;
@end
