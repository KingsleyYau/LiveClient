//
//  ZBGiftLimitNumItemObject.h
//  dating
//
//  Created by Alex on 18/2/27.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <anchorhttpcontroller/ZBHttpRequestEnum.h>

@interface ZBGiftLimitNumItemObject : NSObject
/**
 * 获取主播直播间礼物结构体
 * giftId			礼物ID
 * giftNum			礼物数量
 */

/* 礼物ID */
@property (nonatomic, copy) NSString* giftId;
/* 礼物数量 */
@property (nonatomic, assign) int giftNum;
@end
