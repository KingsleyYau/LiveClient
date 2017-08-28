//
//  SendGiftItem.m
//  livestream
//
//  Created by randy on 2017/8/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SendGiftItem.h"

@implementation SendGiftItem

- (instancetype)initWithGiftItem:(LiveRoomGiftItemObject *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum clickID:(int)clickID{
    
    self = [super init];
    
    if (self) {
        
        self.giftItem = item;
        self.giftNum = giftNum;
        self.starNum = starNum;
        self.endNum = endNum;
        self.clickID = clickID;
    }
    return self;
}

@end
