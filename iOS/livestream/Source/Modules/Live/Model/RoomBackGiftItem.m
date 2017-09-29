//
//  RoomBackGiftItem.m
//  livestream
//
//  Created by randy on 2017/9/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RoomBackGiftItem.h"

@implementation RoomBackGiftItem

- (AllGiftItem *)allItem{
    
    return [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:_giftId];
}


@end
