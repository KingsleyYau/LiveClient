//
//  GiftItem.m
//  livestream
//
//  Created by Max on 2017/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftItem.h"
#import "LiveGiftDownloadManager.h"

@implementation GiftItem

+ (instancetype)itemRoomId:(NSString *)roomid
                  nickName:(NSString *)nickname
               is_Backpack:(NSInteger)is_backpack
                   giftNum:(int)giftnum
                   starNum:(int)starNum
                    endNum:(int)endNum
                   clickID:(int)clickID
                  giftItem:(AllGiftItem *)giftItem {
    
    GiftItem *item = [[GiftItem alloc] init];
    item.roomid = roomid;
    item.nickname = nickname;
    item.is_backpack = is_backpack;
    item.giftnum = giftnum;
    item.multi_click_start = starNum;
    item.multi_click_end = endNum;
    item.multi_click_id = clickID;
    item.giftItem = giftItem;
    
    return item;
}

+ (instancetype)itemRoomId:(NSString *)roomid
              fromID:(NSString *)fromid
            nickName:(NSString *)nickname
              giftID:(NSString *)giftid
            giftName:(NSString *)giftname
                   giftNum:(int)giftnum
               multi_click:(NSInteger)multi_click
                   starNum:(int)starNum
                    endNum:(int)endNum
                   clickID:(int)clickID {
    
    GiftItem *item = [[GiftItem alloc] init];
    item.roomid = roomid;
    item.fromid = fromid;
    item.nickname = nickname;
    item.giftid = giftid;
    item.giftname = giftname;
    item.giftnum = giftnum;
    item.multi_click = multi_click;
    item.multi_click_start = starNum;
    item.multi_click_end = endNum;
    item.multi_click_id = clickID;
    item.giftItem = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:giftid];
    
    return item;
}

- (NSString *)itemId {
    return [NSString stringWithFormat:@"%@_%@_%d", self.fromid, self.giftid, self.multi_click_id, nil];
}

@end
