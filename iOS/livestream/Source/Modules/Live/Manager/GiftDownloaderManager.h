//
//  GiftDownloaderManager.h
//  livestream
//
//  Created by randy on 17/6/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    GiftTypeWindow,   // 大礼物（送出）
    GiftTypeList,     // 中礼物（列表）
    GiftTypeChat      // 小礼物（展示）
} GiftType;


@interface GiftDownloaderManager : NSObject

// 礼物列表
+ (NSArray *)liveGifts;

@property (nonatomic, strong) NSString *giftGoodsURL;   // 礼物的链接图片
@property (nonatomic, strong) NSString *giftGoodsName;  // 商品名称

+ (instancetype)loadManager;

// 下载礼物图片
- (void)downloadLiveGiftWithUrl:(NSString *)imgUrl;

- (UIImage *)imageGiftWithGiftType:(GiftType)type giftId:(int)giftId;

@end
