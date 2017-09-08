//
//  SendGiftItem.h
//  livestream
//
//  Created by randy on 2017/8/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllGiftItem.h"

@interface SendGiftItem : NSObject

@property (nonatomic, strong) AllGiftItem *giftItem;

@property (nonatomic, assign) int giftNum;

@property (nonatomic, assign) int starNum;

@property (nonatomic, assign) int endNum;

@property (nonatomic, assign) int clickID;

@property (nonatomic, copy) NSString* roomID;

@property (nonatomic, copy) NSString* nickName;

@property (nonatomic, assign) BOOL isBackPack;

- (instancetype)initWithGiftItem:(AllGiftItem *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum clickID:(int)clickID roomID:(NSString *)roomID isBackPack:(BOOL)isBackPack;

@end
