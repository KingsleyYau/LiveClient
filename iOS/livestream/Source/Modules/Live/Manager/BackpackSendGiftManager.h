//
//  BackpackSendGiftManager.h
//  livestream
//
//  Created by randy on 2017/8/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackpackGiftItem.h"
#import "RoomBackGiftItem.h"
#import "GiftItem.h"

@class BackpackSendGiftManager;
typedef void (^RequestRoomGiftBlock)(BOOL success,NSMutableArray *backArray);
typedef void (^SendBackpackGiftBlock)(BOOL success,NSMutableArray *backArray);

@interface BackpackSendGiftManager : NSObject


/**
 合并背包礼物字典
 */
@property (nonatomic, strong) NSMutableDictionary *roombackGiftDic;

/**
 合并背包礼物数组
 */
@property (nonatomic, strong) NSMutableArray *roombackGiftArray;

/**
 接口返回数组
 */
@property (nonatomic, strong) NSMutableArray *backGiftArray;

/**
 发送礼物队列
 */
@property (nonatomic, strong) NSMutableArray *sendGiftArray;

@property (nonatomic, strong) RoomBackGiftItem *backGiftItem;

+ (instancetype)backpackGiftManager;

#pragma mark - 请求背包礼物列表
- (void)getBackpackListRequest:(RequestRoomGiftBlock)callBack;

- (int)sendBackpackGiftWithSendGiftItem:(GiftItem *)sendItem;

- (void)updataBackpackGiftList;

- (void)requestSendGiftFail;

@end
