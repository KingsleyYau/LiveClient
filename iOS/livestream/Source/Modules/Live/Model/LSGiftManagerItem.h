//
//  LSGiftManagerItem.h
//  livestream
//
//  Created by randy on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSYYImage.h"

#import "GiftInfoItemObject.h"
#import "GiftWithIdItemObject.h"
#import "BackGiftItemObject.h"

@class LSGiftManagerItem;
@protocol LSGiftManagerItemDownloadDelegate <NSObject>
@optional
- (void)giftDownloadStateChange:(LSGiftManagerItem *)giftItem;
@end

typedef enum{
    GiftSendType_Can_Send = 0,
    GiftSendType_Not_LoveLevel,
    GiftSendType_Not_UserLevel,
}GiftSendType;

@interface LSGiftManagerItem : NSObject

@property (nonatomic, strong) NSString *giftId;
// 下载状态通知
@property (nonatomic, weak) id<LSGiftManagerItemDownloadDelegate> delegate;
// 礼物列表接口数据
@property (nonatomic, strong) GiftInfoItemObject *infoItem;
// 直播间接口数据
@property (nonatomic, strong) GiftWithIdItemObject *roomInfoItem;
// 是否下载中
@property (atomic, assign) BOOL isDownloading;
// 下标
@property (atomic, assign) NSInteger index;
// 背包礼物剩余总量
@property (atomic, assign) NSInteger backpackTotal;
/**
 @return 大礼物WebP本地缓存
 */
- (LSYYImage *)bigGiftImage;

/**
 @return 吧台礼物本地缓存
 */
- (UIImage *)barGiftImage;

/**
 @return 大礼物WebP本地缓存路径
 */
- (NSString *)bigGiftFilePath;

/**
 下载礼物资源
 */
- (void)download;

/**
 是否能发送此礼物

 @param loveLevel 亲密度等级
 @param userLevel 用户等级
 @return 能否发送
 */
- (GiftSendType)canSend:(NSInteger)loveLevel userLevel:(NSInteger)userLevel;

@end
