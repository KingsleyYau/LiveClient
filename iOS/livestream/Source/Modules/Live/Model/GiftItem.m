//
//  GiftItem.m
//  livestream
//
//  Created by Max on 2017/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftItem.h"

@implementation GiftItem

- (NSString *)itemId {
    return [NSString stringWithFormat:@"%@_%@", self.userId, self.giftId, nil];
}

@end
