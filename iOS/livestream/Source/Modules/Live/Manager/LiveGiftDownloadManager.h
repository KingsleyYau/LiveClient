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
#import "BackpackGiftItem.h"

typedef enum {
    DOWNLOADNONE = 0,
    DOWNLOADSTART,
    DOWNLOADING,
    DOWNLOADEND,
    DOWNLOADFAIL
} DownLoadState;

@class LiveGiftDownloadManagerDelegate;
@protocol LiveGiftDownloadManagerDelegate <NSObject>
@optional

- (void)downloadState:(DownLoadState)state;

@end


@class LiveGiftDownloadManager;
typedef void (^RequestFinshtBlock)(BOOL success,NSMutableArray *liveRoomGiftList);

@interface LiveGiftDownloadManager : NSObject

@property (nonatomic, weak)id<LiveGiftDownloadManagerDelegate> managerDelegate;

@property (nonatomic, assign) DownLoadState status;

@property (nonatomic, retain) NSString *path;

@property (nonatomic, strong) NSMutableDictionary *bigGiftDownloadDic;

// 所有礼物对象数组
@property (nonatomic, strong) NSMutableArray<AllGiftItem *> *giftMuArray;

+ (instancetype)manager;

#pragma mark - 下载指定礼物详情
- (void)downLoadGiftDetail:(AllGiftItem *)item;

#pragma mark - 请求礼物列表
- (void)getLiveRoomAllGiftListHaveNew:(BOOL)haveNew request:(RequestFinshtBlock)callBack;

#pragma mark - 下载大礼物webp文件
- (void)afnDownLoadFileWith:(NSString *)fileUrl giftItem:(AllGiftItem *)giftItem;

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
- (void)requestListnotGiftID:(NSString *)giftId;

// 删除大礼物文件
- (void)deletWebpPath:(NSString *)giftId;

// 添加新的礼物Item
//- (void)addNewGIftItemToArray:(LiveRoomGiftItemObject *)item;



@end
