//
//  BackGiftItemObject.h
//  dating
//
//  Created by Alex on 17/8/22.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 礼物列表结构体
 * giftId                 礼物ID
 * num                    礼物数量
 * grantedDate            获取时间（1970年起的秒数）
 * expDate		         过期时间（1970年起的秒数）
 * read                   已读状态（0:未读 1:已读）
 */
@interface BackGiftItemObject : NSObject
@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) int num;
@property (nonatomic, assign) NSInteger grantedDate;
@property (nonatomic, assign) NSInteger expDate;
@property (nonatomic, assign) BOOL read;


@end
