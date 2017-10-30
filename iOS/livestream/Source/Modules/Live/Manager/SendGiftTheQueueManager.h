//
//  SendGiftTheQueueManager.h
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendGiftItem.h"

@class SendGiftTheQueueManager;
@protocol SendGiftTheQueueManagerDelegate <NSObject>
- (void)sendGiftFailWithItem:(SendGiftItem *)item;
- (void)sendGiftNoCredit:(SendGiftItem *)item;
@optional

@end

@interface SendGiftTheQueueManager : NSObject
@property (nonatomic, weak) id<SendGiftTheQueueManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *sendGiftDictionary;
@property (nonatomic, strong) NSMutableArray *sendGiftArray;

/**
 在主线程调用
 */
- (void)unInit;
//-------------- 礼物列表送礼逻辑 -----------------//
/**
 字典增加/替换对象

 @param key 对象key
 @param array 对象数组
 */
- (void)setSendGiftWithKey:(int)key forArray:(NSArray *)array;

/**
 移除指定对象
 */
- (void)removeSendGiftWithKey:(int)key;

/**
 移除所有对象
 */
- (void)removeAllSendGift;

/**
 根据key取对象
 */
- (NSMutableArray *)objectForKey:(int)key;

/**
 取第一个key
 */
- (NSString *)getTheFirstKey;

/**
 发送礼物请求
 */
- (void)sendLiveRoomGiftRequestWithGiftItem:(SendGiftItem *)giftItem;

@end
