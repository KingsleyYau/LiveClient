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
#import "SendGiftItem.h"

@class BackpackSendGiftManager;
typedef void (^RequestRoomGiftBlock)(BOOL success,NSMutableArray *backArray);
typedef void (^SendBackpackGiftBlock)(BOOL success,NSMutableArray *backArray);

@interface BackpackSendGiftManager : NSObject

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
- (void)getGiftListWithRoomid:(NSString *)roomid finshCallback:(RequestRoomGiftBlock)finshCallback;

- (int)sendBackpackGiftWithSendGiftItem:(SendGiftItem *)sendItem;

@end
