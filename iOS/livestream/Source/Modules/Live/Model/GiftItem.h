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
@property (strong) NSString* fromid;             // 发送方的用户ID
@property (strong) NSString* nickname;           //发送方的昵称
@property (strong) NSString* giftid;             //礼物ID
@property (assign) NSInteger giftnum;            // 本次发送礼物的数量（整型）
@property (assign) NSInteger multi_click;        // 是否连击礼物（1：是，0：否）（整型）
@property (assign) NSInteger multi_click_start;  // 连击起始数（整型）（可无，multi_click=0则无）
@property (assign) NSInteger multi_click_end;    // 连击结束数（整型）（可无，multi_click=0则无）
@property (assign) NSInteger multi_click_id;     // 连击ID，相同则表示是同一次连击（整型）（可无，multi_click=0则

+ (instancetype)item:(NSString *)roomid
              fromID:(NSString *)fromid
            nickName:(NSString *)nickname
              giftID:(NSString *)giftid
             giftNum:(NSInteger)giftnum
         multi_click:(NSInteger)multi_click
             starNum:(NSInteger)starNum
              endNum:(NSInteger)endNum
             clickID:(NSInteger)clickID;

@end
