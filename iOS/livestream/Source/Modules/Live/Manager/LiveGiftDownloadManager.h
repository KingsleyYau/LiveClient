//
//  LiveGiftDownloadManager.h
//  livestream
//
//  Created by randy on 2017/6/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetAllGiftListRequest.h"
#import "AllGiftItem.h"

@class LiveGiftDownloadManagerDelegate;
@protocol LiveGiftDownloadManagerDelegate <NSObject>
@optional

- (void)downLoadWasCompleteWithGiftId:(NSString *)giftId;

@end

typedef enum {
    DOWNLOADNONE = 0,
    DOWNLOADSTART,
    DOWNLOADING,
    DOWNLOADEND
} DownLoadState;

@interface LiveGiftDownloadManager : NSObject

@property (nonatomic, weak)id<LiveGiftDownloadManagerDelegate> managerDelegate;

@property (nonatomic, assign) DownLoadState status;

@property (nonatomic, retain) NSString *path;

// 礼物对象数组
@property (nonatomic, strong) NSMutableArray<AllGiftItem *> *giftMuArray;

+ (instancetype)giftDownloadManager;

#pragma mark - 下载大礼物webp文件
- (void)afnDownLoadFileWith:(NSString *)fileUrl giftId:(NSString *)giftId;

// 根据礼物ID判断是否有该礼物
- (BOOL)judgeTheGiftidIsHere:(NSString *)giftId;

// 根据礼物id拿到礼物model
- (AllGiftItem *)backGiftItemWithGiftID:(NSString *)giftId;

// 根据礼物id拿到webP文件路径
- (NSString *)doCheckLocalGiftWithGiftID:(NSString *)giftId;

// 根据礼物id拿到礼物SmallImgUrl
- (NSString *)backSmallImgUrlWithGiftID:(NSString *)giftId;

// 根据礼物id拿到礼物MiddleImgUrl
- (NSString *)backMiddleImgUrlWithGiftID:(NSString *)giftId;

// 根据礼物id拿到礼物BigImgUrl
- (NSString *)backBigImgUrlWithGiftID:(NSString *)giftId;

// 根据礼物id拿到礼物Type
- (GiftType)backImgTypeWithGiftID:(NSString *)giftId;

// 获取指定礼物详情
- (void)requestListnotGift;

// 添加新的礼物Item
//- (void)addNewGIftItemToArray:(LiveRoomGiftItemObject *)item;



@end
