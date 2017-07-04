//
//  GiftItem.m
//  livestream
//
//  Created by Max on 2017/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftItem.h"

@implementation GiftItem

+ (instancetype)item:(NSString *)roomid
              fromID:(NSString *)fromid
            nickName:(NSString *)nickname
              giftID:(NSString *)giftid
             giftNum:(NSInteger)giftnum
         multi_click:(NSInteger)multi_click
             starNum:(NSInteger)starNum
              endNum:(NSInteger)endNum
             clickID:(NSInteger)clickID {
    GiftItem *giftItem = [[GiftItem alloc] init];
    giftItem.roomid = roomid;
    giftItem.fromid = fromid;
    giftItem.nickname = nickname;
    giftItem.giftid = giftid;
    giftItem.giftnum = giftnum;
    giftItem.multi_click = multi_click;
    giftItem.multi_click_start = starNum;
    giftItem.multi_click_end = endNum;
    giftItem.multi_click_id = clickID;
    
    return giftItem;
}

- (NSString *)itemId {
    return [NSString stringWithFormat:@"%@_%@_%ld", self.fromid, self.giftid, (long)self.multi_click_id, nil];
}

@end
