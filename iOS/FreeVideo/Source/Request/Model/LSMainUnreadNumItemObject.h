//
//  LSMainUnreadNumItemObject
//  dating
//
//  Created by Alex on 17/11/01.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LSMainUnreadNumItemObject : NSObject
/**
 * 获取主界面未读数量
 * showTicketUnreadNum          节目未读数量
 * loiUnreadNum                 意向信未读数量
 * emfUnreadNum                 EMF未读数量
 * privateMessageUnreadNum      私信未读数量
 * bookingUnreadNum             预约未读数量
 * backpackUnreadNum            背包未读数量
 * sayHiResponseUnreadNum       sayHi回复未读数量
 */
@property (nonatomic, assign) int showTicketUnreadNum;
@property (nonatomic, assign) int loiUnreadNum;
@property (nonatomic, assign) int emfUnreadNum;
@property (nonatomic, assign) int privateMessageUnreadNum;
@property (nonatomic, assign) int bookingUnreadNum;
@property (nonatomic, assign) int backpackUnreadNum;
@property (nonatomic, assign) int sayHiResponseUnreadNum;

@end
