//
//  SendGiftItem.h
//  livestream
//
//  Created by randy on 2017/8/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoomGiftItemObject.h"

@interface SendGiftItem : NSObject

@property (nonatomic, strong) LiveRoomGiftItemObject *giftItem;

@property (nonatomic, assign) int giftNum;

@property (nonatomic, assign) int starNum;

@property (nonatomic, assign) int endNum;

@property (nonatomic, assign) int clickID;

- (instancetype)initWithGiftItem:(LiveRoomGiftItemObject *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum clickID:(int)clickID;

@end
