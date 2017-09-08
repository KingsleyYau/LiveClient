//
//  SendGiftTheQueueManager.m
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SendGiftTheQueueManager.h"
#import "IMManager.h"

@interface SendGiftTheQueueManager ()

@property (nonatomic, assign) BOOL isFirstSend;

@end

@implementation SendGiftTheQueueManager

+ (instancetype)sendManager {
    
    static SendGiftTheQueueManager *sendManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sendManager = [[SendGiftTheQueueManager alloc] init];
        sendManager.sendGiftDictionary = [[NSMutableDictionary alloc] init];
        sendManager.sendGiftArray = [[NSMutableArray alloc] init];
        sendManager.isFirstSend = YES;
    });
    return sendManager;
}

- (void)setSendGiftWithKey:(int)key forArray:(NSArray *)array {
    
    NSString *objectKey = [NSString stringWithFormat:@"%d",key];
    [self.sendGiftDictionary setObject:array forKey:objectKey];
}

- (void)removeSendGiftWithKey:(int)key {
    
    NSString *objectKey = [NSString stringWithFormat:@"%d",key];
    [self.sendGiftDictionary removeObjectForKey:objectKey];
}

- (void)removeAllSendGift {
    
    [self.sendGiftDictionary removeAllObjects];
}

- (NSMutableArray *)objectForKey:(int)key {
    
    NSString *objectKey = [NSString stringWithFormat:@"%d",key];
    NSMutableArray *comboArray = [self.sendGiftDictionary objectForKey:objectKey];
    return comboArray;
}

- (NSString *)getTheFirstKey {
    
    NSString *firstKey = [self.sendGiftDictionary allKeys].firstObject;
    return firstKey;
}


- (void)sendLiveRoomGiftRequestWithGiftItem:(SendGiftItem *)giftItem{
    
    [self.sendGiftArray addObject:giftItem];
    
    if (self.isFirstSend) {
        [self sendGiftQurest];
        self.isFirstSend = NO;
    }
}

- (void)sendGiftQurest{
    
    IMManager *manager = [IMManager manager];
    
    SendGiftItem *item = self.sendGiftArray[0];
    // 送礼
    [manager sendGift:item.roomID nickName:@"" giftId:item.giftItem.infoItem.giftId giftName:item.giftItem.infoItem.name isBackPack:item.isBackPack giftNum:item.giftNum multi_click:item.giftItem.infoItem.multiClick multi_click_start:item.starNum multi_click_end:item.endNum multi_click_id:item.clickID];
}

// 送礼是否成功通知
- (void)onSendGift:(BOOL)success reqId:(SEQ_T)reqId errType:(LCC_ERR_TYPE)errType errMsg:(NSString *_Nonnull)errmsg credit:(double)credit rebateCredit:(double)rebateCredit {
    
    if (success) {
        
        [self.sendGiftArray removeObjectAtIndex:0];
        
        if (self.sendGiftArray.count) {
            [self sendGiftQurest];
        } else {
            self.isFirstSend = YES;
        }
        
    } else {
        
        [self.sendGiftArray removeAllObjects];
        self.isFirstSend = YES;
    }
}

@end
