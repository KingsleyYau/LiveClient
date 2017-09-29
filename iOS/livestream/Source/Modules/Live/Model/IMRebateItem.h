//
//  IMRebateItem.h
//  livestream
//
//  Created by randy on 2017/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMRebateItem : NSObject

/* 已返点数余额 */
@property (nonatomic, assign) double curCredit;
/* 剩余返点倒数时间（秒） */
@property (nonatomic, assign) int curTime;
/* 每期返点数 */
@property (nonatomic, assign) double preCredit;
/* 返点周期时间 (秒) */
@property (nonatomic, assign) int preTime;

@end
