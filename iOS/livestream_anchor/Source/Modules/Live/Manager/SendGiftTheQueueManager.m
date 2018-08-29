//
//  SendGiftTheQueueManager.m
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SendGiftTheQueueManager.h"
#import "LSAnchorImManager.h"
#import "LSLoginManager.h"

@interface SendGiftTheQueueManager () <ZBIMManagerDelegate, ZBIMLiveRoomManagerDelegate>

@property (nonatomic, assign) BOOL isFirstSend;
@property (nonatomic, strong) LSLoginManager *loginManager;
@property (nonatomic, strong) LSAnchorImManager *imManager;
@property (nonatomic, assign) BOOL isIMNetwork;
@end

@implementation SendGiftTheQueueManager

- (instancetype)init {
    NSLog(@"SendGiftTheQueueManager::init()");
    self = [super init];
    if (self) {
        self.sendGiftDictionary = [[NSMutableDictionary alloc] init];
        self.sendGiftArray = [[NSMutableArray alloc] init];
        self.isFirstSend = YES;
        self.isIMNetwork = YES;
        self.loginManager = [LSLoginManager manager];
        self.imManager = [LSAnchorImManager manager];
        [self.imManager addDelegate:self];
        [self.imManager.client addDelegate:self];
    }
    return self;
}

- (void)unInit {
    [self.imManager removeDelegate:self];
    [self.imManager.client removeDelegate:self];
}

- (void)dealloc {
    NSLog(@"SendGiftTheQueueManager::dealloc()");
}

- (void)setSendGiftWithKey:(int)key forArray:(NSArray *)array {
    NSString *objectKey = [NSString stringWithFormat:@"%d", key];
    [self.sendGiftDictionary setObject:array forKey:objectKey];
}

- (void)removeSendGiftWithKey:(int)key {
    NSString *objectKey = [NSString stringWithFormat:@"%d", key];
    [self.sendGiftDictionary removeObjectForKey:objectKey];
}

- (void)removeAllSendGift {
    [self.sendGiftDictionary removeAllObjects];
}

- (NSMutableArray *)objectForKey:(int)key {
    NSString *objectKey = [NSString stringWithFormat:@"%d", key];
    NSMutableArray *comboArray = [self.sendGiftDictionary objectForKey:objectKey];
    return comboArray;
}

- (NSString *)getTheFirstKey {
    NSString *firstKey = [self.sendGiftDictionary allKeys].firstObject;
    return firstKey;
}

#pragma mark - IM通知
- (void)onZBLogin:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ZBImLoginReturnObject *)item {
    NSLog(@"SendGiftTheQueueManager::onZBLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == ZBLCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == ZBLCC_ERR_SUCCESS) {
            self.isIMNetwork = YES;
        }
    });
}

- (void)onZBLogout:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"SendGiftTheQueueManager::onZBLogout( [IM注销通知], errType : %d, errmsg : %@)", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.sendGiftArray.count) {
            @synchronized(self.sendGiftArray){
                [self.sendGiftArray removeAllObjects];
            }
            self.isIMNetwork = NO;
        }
    });
}

- (void)sendLiveRoomGiftRequestWithGiftItem:(SendGiftItem *)giftItem {
    @synchronized(self.sendGiftArray){
        [self.sendGiftArray addObject:giftItem];
    }
    
    NSLog(@"SendGiftTheQueueManager::sendLiveRoomGiftRequestWithGiftItem( count : %lu )", (unsigned long)self.sendGiftArray.count);

    if (self.isIMNetwork) {
        if (self.isFirstSend) {
            self.isFirstSend = NO;
            [self sendGiftQurest];
        }
    }
}

- (void)sendGiftQurest {
    LSAnchorImManager *manager = [LSAnchorImManager manager];
    SendGiftItem *item = self.sendGiftArray[0];

    // 送礼
    BOOL relues = [manager sendGift:item.roomID
                           nickName:self.loginManager.loginItem.nickName
                             giftId:item.giftItem.infoItem.giftId
                           giftName:item.giftItem.infoItem.name
                         isBackPack:item.isBackPack
                            giftNum:item.giftNum
                        multi_click:item.giftItem.infoItem.multiClick
                  multi_click_start:item.starNum
                    multi_click_end:item.endNum
                     multi_click_id:item.clickID
                      finishHandler:^(BOOL success, ZBLCC_ERR_TYPE errType, NSString *_Nonnull errMsg) {
                          NSLog(@"SendGiftTheQueueManager::sendGiftQurest( [接收发送礼物结果], success : %d, errType : %d, errMsg : %@ )", success, errType, errMsg);

                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (success) {
                                  if (self.sendGiftArray.count > 0) {
                                      @synchronized(self.sendGiftArray){
                                          [self.sendGiftArray removeObjectAtIndex:0];
                                      }
                                  }
                                  NSLog(@"SendGiftTheQueueManager::sendGiftQurest( success, count : %lu )", (unsigned long)self.sendGiftArray.count);

                                  if (self.sendGiftArray.count) {
                                      [self sendGiftQurest];
                                  } else {
                                      self.isFirstSend = YES;
                                  }

                              } else {
                                  NSLog(@"SendGiftTheQueueManager::sendGiftQurest( error, count : %lu )", (unsigned long)self.sendGiftArray.count);
                                  // 发送失败清队列
                                  @synchronized(self.sendGiftArray){
                                      [self.sendGiftArray removeAllObjects];
                                  }
                                  self.isFirstSend = YES;

                                  // 发送大礼物失败回调
                                  if (item.giftItem.infoItem.type == ZBGIFTTYPE_HEIGH) {
                                      if ([self.delegate respondsToSelector:@selector(sendGiftFailWithItem:)]) {
                                          [self.delegate sendGiftFailWithItem:item];
                                      }
                                  }
                              }

                          });
                      }];

    if (!relues) {
        NSLog(@"SendGiftTheQueueManager::sendGiftQurest( relues : %@ )",(relues == YES) ? @"成功" : @"失败");
        @synchronized(self.sendGiftArray){
            [self.sendGiftArray removeAllObjects];
        }
        self.isFirstSend = YES;
        // 发送大礼物失败回调
        if (item.giftItem.infoItem.type == ZBGIFTTYPE_HEIGH) {
            if ([self.delegate respondsToSelector:@selector(sendGiftFailWithItem:)]) {
                [self.delegate sendGiftFailWithItem:item];
            }
        }
    }
}

@end
