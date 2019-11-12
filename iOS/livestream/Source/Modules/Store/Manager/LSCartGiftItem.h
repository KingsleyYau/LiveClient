//
//  LSCartGiftItem.h
//  livestream
//
//  Created by Randy_Fan on 2019/10/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSCartGiftItem : NSObject
/**
 * 鲜花礼品基本信息结构体
 * giftId               礼品ID
 * giftName             礼品名称
 * giftImg              礼品图片
 * giftNumber           礼品数量
 * giftPrice            礼品价格
 * anchorId             主播ID
 */
@property (nonatomic, copy) NSString* giftId;
@property (nonatomic, copy) NSString* giftName;
@property (nonatomic, copy) NSString* giftImg;
@property (nonatomic, assign) int giftNumber;
@property (nonatomic, assign) double giftPrice;
@property (nonatomic, copy) NSString *anchorId;
@end

NS_ASSUME_NONNULL_END
