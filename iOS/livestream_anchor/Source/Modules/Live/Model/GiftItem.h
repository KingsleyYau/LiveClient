//
//  GiftItem.h
//  livestream
//
//  Created by Max on 2017/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GiftItem : NSObject

@property (strong, readonly) NSString* itemId;
@property (strong) NSString* roomid;             // 直播间ID;
@property (strong) NSString* nickname;           // 发送方的昵称
@property (strong) NSString* giftid;             // 礼物ID
@property (strong) NSString* giftname;           // 礼物名称
@property (assign) NSInteger giftnum;            // 本次发送礼物的数量（整型）
@property (assign) NSInteger multi_click;        // 是否连击礼物（1：是，0：否）（整型）
@property (assign) NSInteger multi_click_start;  // 连击起始数（整型）（可无，multi_click=0则无）
@property (assign) NSInteger multi_click_end;    // 连击结束数（整型）（可无，multi_click=0则无）
@property (assign) NSInteger multi_click_id;     // 连击ID，相同则表示是同一次连击（整型）（可无，multi_click=0则

#pragma mark - 发送礼物消息用
@property (assign) NSInteger is_backpack;        // 是否是背包礼物 1：是，0：否）（整型）

#pragma mark - 接收礼物消息用
@property (strong) NSString* fromid;             // 发送方ID


/**
 发送礼物item

 @param roomid 直播间id
 @param nickname 发送方昵称
 @param giftid 礼物id
 @param giftname 礼物名称
 @param is_backpack 是否是背包礼物
 @param giftnum 礼物数量
 @param multi_click 是否是连击礼物
 @param starNum 连击起始数
 @param endNum 连击结束数
 @param clickID 连击id
 @return 发送礼物item
 */
+ (instancetype)itemRoomId:(NSString *)roomid
            nickName:(NSString *)nickname
              giftID:(NSString *)giftid
            giftName:(NSString *)giftname
         is_Backpack:(NSInteger)is_backpack
             giftNum:(NSInteger)giftnum
         multi_click:(NSInteger)multi_click
             starNum:(NSInteger)starNum
              endNum:(NSInteger)endNum
             clickID:(NSInteger)clickID;



/**
 接受礼物item

 @param roomid 房间id
 @param fromid 发送方id
 @param nickname 发送方昵称
 @param giftid 礼物id
 @param giftname 礼物名称
 @param giftnum 礼物数量
 @param multi_click 是否是连击礼物
 @param starNum 连击起始数
 @param endNum 连击结束数
 @param clickID 连击id
 @return 接收礼物item
 */
+ (instancetype)itemRoomId:(NSString *)roomid
              fromID:(NSString *)fromid
            nickName:(NSString *)nickname
              giftID:(NSString *)giftid
            giftName:(NSString *)giftname
             giftNum:(NSInteger)giftnum
         multi_click:(NSInteger)multi_click
             starNum:(NSInteger)starNum
              endNum:(NSInteger)endNum
             clickID:(NSInteger)clickID;



@end
