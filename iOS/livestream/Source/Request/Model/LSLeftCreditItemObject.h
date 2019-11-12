//
//  LSLeftCreditItemObject.h
//  dating
//
//  Created by Alex on 19/6/20.
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LSLeftCreditItemObject : NSObject
{

}
/**
 * 余额信息
 * credit       信用点
 * coupon       可用的试用券数量
 * liveChatCount  可用livechat的试用券数量
 * postStamp    可用的邮票数量
 */
@property (nonatomic, assign) double credit;
@property (nonatomic, assign) int coupon;
@property (nonatomic, assign) int liveChatCount;
@property (nonatomic, assign) double postStamp;

@end
