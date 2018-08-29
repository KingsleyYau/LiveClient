//
//  SendGiftTheQueueManager.h
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GiftItem.h"

@class SendGiftTheQueueManager;
@protocol SendGiftTheQueueManagerDelegate <NSObject>
- (void)sendGiftFailWithItem:(GiftItem *)item;
- (void)sendGiftNoCredit:(GiftItem *)item;
@optional

@end

@interface SendGiftTheQueueManager : NSObject
@property (nonatomic, weak) id<SendGiftTheQueueManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *sendGiftArray;
@property (nonatomic, assign) NSInteger isPrivate;
@property (nonatomic, copy) NSString *toUid;


/**
 初始化方法
 */
+ (instancetype)manager;

/**
 在主线程调用
 */
- (void)unInit;

/**
 移除所有对象
 */
- (void)removeAllSendGift;

/**
 普通直播间发送礼物请求
 */
- (void)sendLiveRoomGiftRequestWithGiftItem:(GiftItem *)giftItem;

/**
 多人互动直播间发送礼物请求
 */
- (void)sendHangoutGiftrRequestWithGiftItem:(GiftItem *)giftItem;

@end
