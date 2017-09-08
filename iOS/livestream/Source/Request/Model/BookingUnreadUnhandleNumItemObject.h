//
//  BookingUnreadUnhandleNumItemObject.h
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 预约列表数量结构体
 * @total                 以下参数数量总和
 * @handleNum             待观众处理的数量
 * @scheduledUnreadNum    已接受的未读数量
 * @historyUnreadNum      历史超时、拒绝的未读数量
 */

@interface BookingUnreadUnhandleNumItemObject : NSObject
@property (nonatomic, assign) int total;
@property (nonatomic, assign) int handleNum;
@property (nonatomic, assign) int scheduledUnreadNum;
@property (nonatomic, assign) int historyUnreadNum;
@end
