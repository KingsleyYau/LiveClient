//
//  SendGiftItem.m
//  livestream
//
//  Created by randy on 2017/8/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SendGiftItem.h"
#import "LoginManager.h"

@implementation SendGiftItem

- (instancetype)initWithGiftItem:(AllGiftItem *)item andGiftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum clickID:(int)clickID roomID:(NSString *)roomID isBackPack:(BOOL)isBackPack {
    
    self = [super init];
    
    if (self) {
        
        LoginManager *manager = [LoginManager manager];
        
        self.giftItem = item;
        self.giftNum = giftNum;
        self.starNum = starNum;
        self.endNum = endNum;
        self.clickID = clickID;
        self.roomID = roomID;
        self.nickName = manager.loginItem.nickName;
        self.isBackPack = isBackPack;
    }
    return self;
}

@end
