//
//  GiftModel.h
//  livestream
//
//  Created by randy on 17/6/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftModel : NSObject
/**
 *  礼物ID
 */
@property (nonatomic, copy) NSString *giftId;

/**
 *  礼物名称
 */
@property (nonatomic, copy) NSString *name;

/**
 *  列表图片Url
 */
@property (nonatomic, copy) NSString *imgurl;

/**
 *  礼物图片Url
 */
@property (nonatomic, copy) NSString *srcurl;

/**
 *  赠送礼物消费的金币
 */
@property (nonatomic, assign) float coins;

/**
 *  是否连击
 */
@property (nonatomic, assign) int multi_click;

/**
 *  礼物类型
 */
@property (nonatomic, assign) int type;

/**
 *  礼物最后更新时间戳
 */
@property (nonatomic, assign) int update_time;

@end
