//
//  SendGiftTheQueueManager.m
//  livestream
//
//  Created by randy on 2017/8/10.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SendGiftTheQueueManager.h"
#import "LSImManager.h"
#import "LSLoginManager.h"
#import "LSGiftManager.h"

@interface SendGiftTheQueueManager () <IMManagerDelegate, IMLiveRoomManagerDelegate>

@property (nonatomic, assign) BOOL isFirstSend;
@property (nonatomic, strong) LSLoginManager *loginManager;
@property (nonatomic, strong) LSImManager *imManager;
@property (nonatomic, strong) LSGiftManager *giftManager;
@property (nonatomic, assign) BOOL isIMNetwork;
@end

@implementation SendGiftTheQueueManager

+ (instancetype)manager {
    SendGiftTheQueueManager *manager = [[SendGiftTheQueueManager alloc] init];
    return manager;
}

- (instancetype)init {
    NSLog(@"SendGiftTheQueueManager::init()");
    self = [super init];
    if (self) {
        self.sendGiftArray = [[NSMutableArray alloc] init];
        self.isFirstSend = YES;
        self.isIMNetwork = YES;
        self.loginManager = [LSLoginManager manager];
        self.imManager = [LSImManager manager];
        self.giftManager = [LSGiftManager manager];
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

- (void)removeAllSendGift {
    @synchronized(self.sendGiftArray){
        [self.sendGiftArray removeAllObjects];
    }
}

#pragma mark - IM通知
- (void)onLogin:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg item:(ImLoginReturnObject *)item {
    NSLog(@"SendGiftTheQueueManager::onLogin( [IM登陆, %@], errType : %d, errmsg : %@ )", (errType == LCC_ERR_SUCCESS) ? @"成功" : @"失败", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == LCC_ERR_SUCCESS) {
            self.isIMNetwork = YES;
            self.isFirstSend = YES;
        }
    });
}

- (void)onLogout:(LCC_ERR_TYPE)errType errMsg:(NSString *)errmsg {
    NSLog(@"SendGiftTheQueueManager::onLogout( [IM注销通知], errType : %d, errmsg : %@)", errType, errmsg);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.sendGiftArray.count > 0) {
            @synchronized(self.sendGiftArray){
                [self.sendGiftArray removeAllObjects];
            }
            self.isIMNetwork = NO;
            self.isFirstSend = NO;
        }
    });
}

- (void)sendLiveRoomGiftRequestWithGiftItem:(GiftItem *)giftItem {
    // IM连接,送礼插队列
    if (self.isIMNetwork) {
        [self.sendGiftArray addObject:giftItem];
        
    } else {
        // IM断线,清队列
        @synchronized(self.sendGiftArray){
            if (self.sendGiftArray.count > 0) {
                [self.sendGiftArray removeAllObjects];
            }
        }
    }
    if (self.isFirstSend) {
        self.isFirstSend = NO;
        [self sendGiftQurest];
    }
}

- (void)sendGiftQurest {
    LSImManager *manager = [LSImManager manager];
    GiftItem *item = self.sendGiftArray[0];
    NSLog(@"SendGiftTheQueueManager::sendGiftQurest( [发送礼物] giftId : %@ )", item.giftItem.infoItem.giftId);
    
    // 送礼
    BOOL relues = [manager sendGift:item.roomid
                           nickName:self.loginManager.loginItem.nickName
                             giftId:item.giftItem.infoItem.giftId
                           giftName:item.giftItem.infoItem.name
                         isBackPack:item.is_backpack
                            giftNum:item.giftnum
                        multi_click:item.giftItem.infoItem.multiClick
                  multi_click_start:item.multi_click_start
                    multi_click_end:item.multi_click_end
                     multi_click_id:item.multi_click_id
                      finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, double credit, double rebateCredit) {
                          NSLog(@"SendGiftTheQueueManager::sendGiftQurest( [接收发送礼物结果], success : %d, errType : %d, errMsg : %@, credit : %f, rebateCredit : %f )", success, errType, errMsg, credit, rebateCredit);

                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (success) {
                                  if (self.sendGiftArray.count > 0) {
                                      @synchronized(self.sendGiftArray){
                                          [self.sendGiftArray removeObjectAtIndex:0];
                                      }
                                  }
                                  if (self.sendGiftArray.count > 0) {
                                      [self sendGiftQurest];
                                  } else {
                                      self.isFirstSend = YES;
                                  }

                              } else {
                                  // 发送失败清队列
                                  @synchronized(self.sendGiftArray){
                                      [self.sendGiftArray removeAllObjects];
                                  }
                                  self.isFirstSend = YES;

                                  // 发送大礼物失败回调
                                  if (item.giftItem.infoItem.type == GIFTTYPE_Heigh) {
                                      if ([self.delegate respondsToSelector:@selector(sendGiftFailWithItem:)]) {
                                          [self.delegate sendGiftFailWithItem:item];
                                      }
                                  }

                                  // 信用点不足发送失败
                                  if (errType == LCC_ERR_NO_CREDIT) {
                                      if ([self.delegate respondsToSelector:@selector(sendGiftNoCredit:)]) {
                                          [self.delegate sendGiftNoCredit:item];
                                      }
                                  }
                              }

                          });
                      }];

    if (!relues) {
        NSLog(@"SendGiftTheQueueManager::sendGiftQurest( 发送礼物 断网 )");
        @synchronized(self.sendGiftArray){
            [self.sendGiftArray removeAllObjects];
        }
        self.isFirstSend = YES;
        // 发送大礼物失败回调
        if (item.giftItem.infoItem.type == GIFTTYPE_Heigh) {
            if ([self.delegate respondsToSelector:@selector(sendGiftFailWithItem:)]) {
                [self.delegate sendGiftFailWithItem:item];
            }
        }
    }
}

- (void)sendHangoutGiftrRequestWithGiftItem:(GiftItem *)giftItem {
    // IM连接,送礼插队列
    if (self.isIMNetwork) {
        [self.sendGiftArray addObject:giftItem];
        
    } else {
        // IM断线,清队列
        @synchronized(self.sendGiftArray){
            if (self.sendGiftArray.count > 0) {
                [self.sendGiftArray removeAllObjects];
            }
        }
    }
    // 发送多人互动礼物
    if (self.isFirstSend) {
        self.isFirstSend = NO;
        [self sendHangoutGift];
    }
}

- (void)sendHangoutGift {
    LSImManager *manager = [LSImManager manager];
    GiftItem *item = self.sendGiftArray[0];
    NSLog(@"SendGiftTheQueueManager::sendHangoutGift( [发送多人互动礼物] giftId : %@ )",item.giftItem.infoItem.giftId);
    
    BOOL relues = [manager sendHangoutGift:item.roomid nickName:self.loginManager.loginItem.nickName toUid:self.toUid giftId:item.giftItem.infoItem.giftId giftName:item.giftItem.infoItem.name isBackPack:item.is_backpack giftNum:item.giftnum isMultiClick:item.giftItem.infoItem.multiClick multiClickStart:item.multi_click_start multiClickEnd:item.multi_click_end multiClickId:item.multi_click_id isPrivate:item.isPrivate finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString * _Nonnull errMsg, double credit) {
        NSLog(@"SendGiftTheQueueManager::sendHangoutGift( [接收多人互动发送礼物结果], success : %@, errType : %d, errMsg : %@, credit : %f)", success == YES ? @"成功":@"失败", errType, errMsg, credit);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // 发送成功继续发送
                if (self.sendGiftArray.count > 0) {
                    @synchronized(self.sendGiftArray){
                        [self.sendGiftArray removeObjectAtIndex:0];
                    }
                }
                if (self.sendGiftArray.count > 0) {
                    [self sendHangoutGift];
                } else {
                    self.isFirstSend = YES;
                }
                
            } else {
                // 发送失败清队列
                @synchronized(self.sendGiftArray){
                    [self.sendGiftArray removeAllObjects];
                }
                self.isFirstSend = YES;
            }
        });
    }];
    if (!relues) {
        NSLog(@"SendGiftTheQueueManager::sendHangoutGift( 发送多人互动礼物 断网 )");
        @synchronized(self.sendGiftArray){
            [self.sendGiftArray removeAllObjects];
        }
        self.isFirstSend = YES;
    }
}



@end
