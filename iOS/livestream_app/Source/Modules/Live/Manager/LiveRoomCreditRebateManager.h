//
//  LiveRoomCreditRebateManager.h
//  livestream
//
//  Created by alex shum on 17/9/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMRebateItem.h"

@class LiveRoomCreditRebateManager;
@protocol LiveRoomCreditRebateManagerDelegate <NSObject>
@optional
- (void)updataCredit:(double)credit;
@end


@interface LiveRoomCreditRebateManager : NSObject

@property (nonatomic, assign) double mCredit;
@property (nonatomic, strong) IMRebateItem *imRebateItem;
@property (nonatomic, weak) id<LiveRoomCreditRebateManagerDelegate> delegate;

/** 单例实例 */
+ (instancetype)creditRebateManager;

- (BOOL)addDelegate:(id<LiveRoomCreditRebateManagerDelegate> )delegate;

- (BOOL)removeDelegate:(id<LiveRoomCreditRebateManagerDelegate> )delegate;

//请求账号余额
- (void)getLeftCreditRequest;
// 设置信用点
- (void)setCredit:(double)credit;
// 获取信用点
- (double)getCredit;
// 设置返点信息
- (void)setReBateItem:(IMRebateItem*)rebateItem;
// 获取返点信息
- (IMRebateItem *)getReBateItem;
// 更新返点总数
- (void)updateRebateCredit:(double)rebateCredit;

@end
