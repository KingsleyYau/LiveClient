//
//  RebateInfoObject.h
//  dating
//
//  Created by Alex on 17/8/15.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

// 返点信息队列
@interface RebateInfoObject : NSObject
/* 已返点数余额 */
@property (nonatomic, assign) double curCredit;
/* 剩余返点倒数时间（秒） */
@property (nonatomic, assign) int curTime;
/* 每期返点数 */
@property (nonatomic, assign) double preCredit;
/* 返点周期时间 (秒) */
@property (nonatomic, assign) int preTime;

@end
