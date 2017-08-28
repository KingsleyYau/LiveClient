//
//  SendGiftTheQueueManager.h
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendGiftItem.h"

@interface SendGiftTheQueueManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *sendGiftDictionary;

@property (nonatomic, strong) NSMutableArray *clickIdArray;

/** 实例单例 */
+ (instancetype)sendManager;

//-------------- 礼物列表送礼逻辑 -----------------//

/** 增加/替换对象 */
- (void)setSendGiftWithKey:(int)key forArray:(NSArray *)array;

/** 移除对象 */
- (void)removeSendGiftWithKey:(int)key;

/** 添加连击ID */
- (void)addItemWithClickID:(int)clickId giftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum andGiftItem:(LiveRoomGiftItemObject *)item;

/** 移除所有对象 */
- (void)removeAllSendGift;

/** 根据key取对象 */
- (NSMutableArray *)objectForKey:(int)key;

/** 取第一个key */
- (NSString *)getTheFirstKey;

/** 发送礼物请求 */
- (void)sendLiveRoomGiftRequestWithGiftItem:(SendGiftItem *)item roomID:(NSString *)roomId  multiClickID:(int)multi_click_id;

@end
