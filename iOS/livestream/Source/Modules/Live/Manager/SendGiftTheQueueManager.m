//
//  SendGiftTheQueueManager.m
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SendGiftTheQueueManager.h"
#import "IMManager.h"

@implementation SendGiftTheQueueManager

+ (instancetype)sendManager {
    
    static SendGiftTheQueueManager *sendManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sendManager = [[SendGiftTheQueueManager alloc] init];
        sendManager.sendGiftDictionary = [[NSMutableDictionary alloc] init];
        sendManager.clickIdArray = [[NSMutableArray alloc] init];
    });
    return sendManager;
}

- (void)setSendGiftWithKey:(int)key forArray:(NSArray *)array {
    
    NSString *objectKey = [NSString stringWithFormat:@"%d",key];
    [self.sendGiftDictionary setObject:array forKey:objectKey];
}

- (void)addItemWithClickID:(int)clickId giftNum:(int)giftNum starNum:(int)starNum endNum:(int)endNum andGiftItem:(LiveRoomGiftItemObject *)item{

    SendGiftItem *sendItem = [[SendGiftItem alloc] initWithGiftItem:item andGiftNum:giftNum starNum:starNum endNum:endNum clickID:clickId];
    [self.clickIdArray addObject:sendItem];
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


- (void)sendLiveRoomGiftRequestWithGiftItem:(SendGiftItem *)item roomID:(NSString *)roomId  multiClickID:(int)multi_click_id {
    
    IMManager *manager = [IMManager manager];
    
    [manager sendRoomGiftWithRoomId:roomId giftId:item.giftItem.giftId giftName:item.giftItem.name giftNum:item.giftNum multi_click:item.giftItem.multi_click multi_click_start:item.starNum multi_click_end:item.endNum multi_click_id:multi_click_id];
}

- (void)sendLiveRoomGiftRequestWithEoomID:(NSString *)roomId {
    
    if ( self.clickIdArray.count ) {
        
        SendGiftItem *item = [self.clickIdArray firstObject];
        IMManager *manager = [IMManager manager];
        
        [manager sendRoomGiftWithRoomId:roomId giftId:item.giftItem.giftId giftName:item.giftItem.name giftNum:item.giftNum multi_click:item.giftItem.multi_click multi_click_start:item.starNum multi_click_end:item.endNum multi_click_id:item.clickID];
    }
}

@end
