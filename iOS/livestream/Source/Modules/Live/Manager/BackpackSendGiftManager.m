//
//  BackpackSendGiftManager.m
//  livestream
//
//  Created by randy on 2017/8/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BackpackSendGiftManager.h"

@implementation BackpackSendGiftManager

+ (instancetype)backpackGiftManager {
    
    static BackpackSendGiftManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[BackpackSendGiftManager alloc] init];
        manager.backGiftArray = [[NSMutableArray alloc] init];
        manager.backpackItem = [[BackpackGiftItem alloc] init];
    });
    
    return manager;
}


- (void)sendBackpackGiftID:(NSString *)giftID giftNum:(int)giftNum statNum:(int)starNum endNum:(int)endNum finishHanld:(SendBackpackGiftBlock)block {
    
    
    BackpackGiftItem *backpackItem = [[BackpackGiftItem alloc] init];
    NSUInteger index = -1;
    
    for ( BackpackGiftItem *giftItem in self.backGiftArray ) {
        
        if ( [giftItem.item.giftId isEqualToString:giftID] ) {
            
            index = [self.backGiftArray indexOfObject:giftItem];
            backpackItem = giftItem;
        }
    }
    
    /** 判断背包礼物数量是否够送 */
    if ( backpackItem.giftNum - giftNum ) {
        
        // 礼物数量减掉发送数量 替换礼物Object
        backpackItem.giftNum = backpackItem.giftNum - giftNum;
        [self.backGiftArray replaceObjectAtIndex:index withObject:backpackItem];
        
        // 发送礼物请求
        block(YES, self.backGiftArray);
        
        
    }else {
        
        // 返回失败
        block(NO, self.backGiftArray);
    }
}

- (void)updataBackpackGiftList {
    
    
    
}

- (void)requestSendGiftFail {
    
    
}



@end
