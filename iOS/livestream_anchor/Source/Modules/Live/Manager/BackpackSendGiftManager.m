//
//  BackpackSendGiftManager.m
//  livestream
//
//  Created by randy on 2017/8/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BackpackSendGiftManager.h"
#import "LSLoginManager.h"
#import "ZBLSRequestManager.h"
#import "ZBLSImManager.h"

@interface BackpackSendGiftManager () <LoginManagerDelegate>

@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, assign) BOOL isFirstSend;

@end

@implementation BackpackSendGiftManager

+ (instancetype)backpackGiftManager {

    static BackpackSendGiftManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BackpackSendGiftManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        LSLoginManager *logManager = [LSLoginManager manager];
        [logManager addDelegate:self];
        self.backGiftArray = [[NSMutableArray alloc] init];
        self.backGiftItem = [[RoomBackGiftItem alloc] init];
        self.loginManager = [LSLoginManager manager];
        self.sendGiftArray = [[NSMutableArray alloc] init];
        self.isFirstSend = YES;
    }
    return self;
}

#pragma mark - 请求背包礼物列表
- (void)getGiftListWithRoomid:(NSString *)roomid finshCallback:(RequestRoomGiftBlock)finshCallback {
    
    [[ZBLSRequestManager manager] anchorGiftList:roomid finishHandler:^(BOOL success, ZBHTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSArray<ZBGiftLimitNumItemObject *> * _Nullable array) {
        NSLog(@"BackpackSendGiftManager::AnchorGiftList( [主播获取直播间礼物列表], success : %d, errnum : %ld, errmsg : %@, count : %u )", success, (long)errnum, errmsg, (unsigned int)array.count);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 请求成功 清空旧数据
            [self.backGiftArray removeAllObjects];
            if (array.count) {
                for (ZBGiftLimitNumItemObject *object in array) {
                    RoomBackGiftItem *item = [[RoomBackGiftItem alloc] init];
                    item.giftId = object.giftId;
                    item.giftNum = object.giftNum;
                    [self.backGiftArray addObject:item];
                }
                finshCallback(success, self.backGiftArray);
                
            } else {
                finshCallback(success, nil);
            }
            
        });
    }];
}

/**
 发送背包礼物
 
 successType 0  背包礼物不足
 successType 1  发送成功
 successType 2  发送成功并且刚好送完

 @param sendItem 发送礼物item
 @return 发送类型
 */
- (int)sendBackpackGiftWithSendGiftItem:(SendGiftItem *)sendItem {

    int successType = -1;

    // 遍历合成礼物数组 拿到发送的礼物item
    RoomBackGiftItem *backGiftItem = [[RoomBackGiftItem alloc] init];
    NSUInteger index = -1;

    for (RoomBackGiftItem *giftItem in self.backGiftArray) {

        if ([giftItem.giftId isEqualToString:sendItem.giftItem.infoItem.giftId]) {
            index = [self.backGiftArray indexOfObject:giftItem];
            backGiftItem = giftItem;
        }
    }

    /** 判断背包礼物数量是否够送 */
    int remainNum = backGiftItem.giftNum - sendItem.giftNum;
    if (remainNum > 0) {

        // 添加礼物到发送队列 并发送礼物请求
        [self addItemInQueueAndSend:sendItem];

        // 礼物数量减掉发送数量 替换礼物Object
        backGiftItem.giftNum = remainNum;
        [self.backGiftArray replaceObjectAtIndex:index withObject:backGiftItem];
        successType = 1;

    } else if (remainNum == 0) {

        [self addItemInQueueAndSend:sendItem];
        // 礼物送完移出合成礼物队列
        [self.backGiftArray removeObjectAtIndex:index];
        successType = 2;

    } else {
        successType = 0;
    }

    return successType;
}

- (void)addItemInQueueAndSend:(SendGiftItem *)sendItem {

    [self.sendGiftArray addObject:sendItem];
    if (self.isFirstSend) {
        [self sendBackGiftQurest];
        self.isFirstSend = NO;
    }
}

- (void)sendBackGiftQurest {

    ZBLSImManager *manager = [ZBLSImManager manager];
    SendGiftItem *item = self.sendGiftArray[0];
    
    // 送礼
    BOOL result = [manager sendGift:item.roomID
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

                NSLog(@"BackpackSendGiftManager::sendBackGiftQurest( [接收发送背包礼物结果], success : %d, errType : %d, errMsg : %@)", success, errType, errMsg);

                dispatch_async(dispatch_get_main_queue(), ^{

                    if (success) {
                        if (self.sendGiftArray.count > 0) {
                            [self.sendGiftArray removeObjectAtIndex:0];
                        }
                        if (self.sendGiftArray.count) {
                            [self sendBackGiftQurest];
                        } else {
                            self.isFirstSend = YES;
                        }
                    } else {

                        [self.sendGiftArray removeAllObjects];
                        self.isFirstSend = YES;
                    }
                });
            }];
    
    if (!result) {
        [self.sendGiftArray removeAllObjects];
        self.isFirstSend = YES;
    }
}



@end
