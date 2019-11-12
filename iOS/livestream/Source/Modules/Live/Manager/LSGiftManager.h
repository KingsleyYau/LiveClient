//
//  LSGiftManager.h
//  livestream
//
//  Created by randy on 2017/6/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetAllGiftListRequest.h"
#import "LSGiftManagerItem.h"
#import "LSGetHangoutGiftListRequest.h"
#import "LSGetGiftTypeListRequest.h"
#import "GiftItem.h"

@class LSGiftManagerDelegate;
@protocol LSGiftManagerDelegate <NSObject>
@optional
- (void)giftDownloadManagerBigGiftChange:(LSGiftManagerItem *)LSGiftManagerItem index:(NSInteger)index;
- (void)giftDownloadManagerStateChange:(LSGiftManagerItem *)LSGiftManagerItem index:(NSInteger)index;
@end

@class LSGiftManager;
typedef void (^GetGiftFinshtHandler)(BOOL success, NSArray<LSGiftManagerItem *> *giftList);
typedef void (^GetHangoutGiftFinshHandler)(BOOL success, NSArray<LSGiftManagerItem *> *buyforList, NSArray<LSGiftManagerItem *> *normalList, NSArray<LSGiftManagerItem *> *celebrationList);
typedef void (^GetGiftTypeListFinishHandler)(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSGiftTypeItemObject *> *array);
@interface LSGiftManager : NSObject
#pragma mark - 属性
/**
 礼物下载状态回调
 */
@property (nonatomic, weak) id<LSGiftManagerDelegate> delegate;

#pragma mark - 获取实例
+ (instancetype)manager;

#pragma mark - 获取礼物
/**
 获取礼物列表

 @param finshHandler 完成回调
 */
- (void)getAllGiftList:(GetGiftFinshtHandler)finshHandler;

/**
 获取直播间可显示的礼物列表

 @param roomId 房间Id
 @param finshHandler 完成回调
 */
- (void)getRoomGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler;

/**
 获取直播间随机礼物列表

 @param roomId 房间Id
 @param finshHandler 完成回调
 */
- (void)getRoomRandomGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler;

/**
 获取背包礼物列表
 根据Id做合并, 不会显示多条记录
 @param finshHandler 完成回调
 */
- (void)getAllBackpackGiftList:(GetGiftFinshtHandler)finshHandler;

/**
 获取直播间可显示的背包礼物列表
 
 @param roomId 房间Id
 @param finshHandler 完成回调
 */
- (void)getRoomBackpackGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler;


/**
 获取私密直播间可显示的背包礼物列表

 @param roomId 房间Id
 @param finshHandler 完成回调
 */
- (void)getPraviteRoomBackpackGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler;

/**
 获取多人互动直播间可发送礼物列表

 @param roomId 房间Id
 @param finshHandler 完成回调
 */
- (void)getHangoutGiftList:(NSString *)roomId finshHandler:(GetHangoutGiftFinshHandler)finshHandler;

/**
 获取虚拟礼物分类列表
 
 @param roomType 房间类型 1为公开 2为私密
 @param finshHandler 完成回调
 */
- (void)getGiftTypeList:(NSInteger)roomType finshHandler:(GetGiftTypeListFinishHandler)finshHandler;

/**
 根据礼物类型获取礼物列表
 @param roomId 房间id
 @param typeId 类型id
 @param finshHandler 完成回调
 */
- (void)getGiftTypeContent:(NSString *)roomId typeID:(NSString *)typeId finshHandler:(GetGiftFinshtHandler)finshHandler;
/**
 获取指定礼物
 @param giftId 礼物Id
 @return 礼物实例
 */
- (LSGiftManagerItem *)getGiftItemWithId:(NSString *)giftId;

/**
 清除所有缓存礼物列表
 */
- (void)removeAllGiftList;

/**
 清除直播间缓存礼物列表
 */
- (void)removeRoomGiftList;

/**
 清除多人互动直播间缓存礼物列表
 */
- (void)removeHangoutGiftList;

@end
