//
//  BackpackGiftItem.h
//  livestream
//
//  Created by randy on 2017/8/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackpackGiftItem : NSObject
/**
 * 礼物列表结构体
 * giftId                 礼物ID
 * num                    礼物数量
 * grantedDate            获取时间（1970年起的秒数）
 * expDate		         过期时间（1970年起的秒数）
 * read                   已读状态（0:未读 1:已读）
 */
@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) int num;
@property (nonatomic, assign) NSInteger grantedDate;
@property (nonatomic, assign) NSInteger expDate;
@property (nonatomic, assign) BOOL read;

@end
