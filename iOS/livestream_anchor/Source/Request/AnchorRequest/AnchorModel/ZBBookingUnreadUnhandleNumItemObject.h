//
//  ZBBookingUnreadUnhandleNumItemObject.h
//  dating
//
//  Created by Alex on 18/2/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 预约列表数量结构体
 * @totalNoReadNum              以下参数数量总和
 * @pendingNoReadNum            待观众处理的数量
 * @scheduledNoReadNum          已接受的未读数量
 * @historyUnreadNum            历史超时、拒绝的未读数量
 */

@interface ZBBookingUnreadUnhandleNumItemObject : NSObject
@property (nonatomic, assign) int totalNoReadNum;
@property (nonatomic, assign) int pendingNoReadNum;
@property (nonatomic, assign) int scheduledNoReadNum;
@property (nonatomic, assign) int historyNoReadNum;
@end
