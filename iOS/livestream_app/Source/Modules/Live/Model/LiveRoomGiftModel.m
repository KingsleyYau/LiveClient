//
//  LiveRoomGiftModel.m
//  livestream
//
//  Created by randy on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveRoomGiftModel.h"

@implementation LiveRoomGiftModel

- (void)setGiftId:(NSString *)giftId{
    
    _giftId = giftId;
    _allItem = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:_giftId];
    
}

@end
