//
//  BackpackSendGiftManager.m
//  livestream
//
//  Created by randy on 2017/8/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BackpackSendGiftManager.h"
#import "GiftListRequest.h"
#import "LoginManager.h"
#import "IMManager.h"

@interface BackpackSendGiftManager () <LoginManagerDelegate>

@property (nonatomic, strong) SessionRequestManager *sessionManager;

@property (nonatomic, strong) LoginManager *loginManager;

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
        LoginManager *logManager = [LoginManager manager];
        [logManager addDelegate:self];
        self.backGiftArray = [[NSMutableArray alloc] init];
        self.roombackGiftArray = [[NSMutableArray alloc] init];
        self.roombackGiftDic = [[NSMutableDictionary alloc] init];
        self.backGiftItem = [[RoomBackGiftItem alloc] init];
        self.sessionManager = [SessionRequestManager manager];
        self.loginManager = [LoginManager manager];
        self.sendGiftArray = [[NSMutableArray alloc] init];
        self.isFirstSend = YES;
    }
    return self;
}

// 监听HTTP登录
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSInteger)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            // 请求背包礼物列表
            [self getBackpackListRequest:^(BOOL success, NSMutableArray *backArray){
            }];
        }
    });
}

#pragma mark - 请求背包礼物列表
- (void)getBackpackListRequest:(RequestRoomGiftBlock)callBack {

    GiftListRequest *request = [[GiftListRequest alloc] init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg,
                              NSArray<BackGiftItemObject *> * _Nullable array, int totalCount) {
        
        NSLog(@"BackpackSendGiftManager::GiftListRequest[发送获取背包礼物列表请求结果] success:%d"
               " ErrNum:%ld ErrMsg:%@ array:%@",
              success, (long)errnum, errmsg, array);

        dispatch_async(dispatch_get_main_queue(), ^{

            if (success) {
                if (array != nil && array.count) {
                    for (BackGiftItemObject *object in array) {
                        BackpackGiftItem *item = [[BackpackGiftItem alloc] init];
                        item.giftId = object.giftId;
                        item.num = object.num;
                        item.grantedDate = object.grantedDate;
                        item.expDate = object.expDate;
                        item.read = object.read;
                        [self.backGiftArray addObject:item];

                        if (self.backGiftArray.count == array.count) {
                            if ([self screenGiftIdSame]) {
                                callBack(success, self.roombackGiftArray);
                            }
                        }
                    }
                }
            } else {
                self.roombackGiftArray = nil;
                callBack(success, self.roombackGiftArray);
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

// 遍历背包礼物数组 合并相同礼物id礼物
- (BOOL)screenGiftIdSame {
    BOOL isFinsh = NO;
    RoomBackGiftItem *item = [[RoomBackGiftItem alloc] init];
    RoomBackGiftItem *roomItem = [[RoomBackGiftItem alloc] init];

    for (int i = 0; i < self.backGiftArray.count; i++) {
        item = self.backGiftArray[i];
        roomItem = [self.roombackGiftDic objectForKey:item.giftId];
        if (roomItem) {
            roomItem.num = roomItem.num + item.num;
        } else {
            roomItem = [[RoomBackGiftItem alloc] init];
            roomItem.num = item.num;
            roomItem.giftId = item.giftId;
        }
        [self.roombackGiftDic setObject:roomItem forKey:item.giftId];

        if (i == self.backGiftArray.count - 1) {
            isFinsh = [self dicConverArray];
        }
    }
    return isFinsh;
}

// 遍历直播间背包礼物字典 字典转换成数组
- (BOOL)dicConverArray {
    BOOL isFinsh = NO;
    NSArray *keys = [self.roombackGiftDic allKeys];
    for (int i = 0; i < keys.count; i++) {
        RoomBackGiftItem *roomItem = [self.roombackGiftDic objectForKey:keys[i]];
        [self.roombackGiftArray addObject:roomItem];
        if (i == keys.count - 1) {
            isFinsh = YES;
        }
    }
    return isFinsh;
}

- (int)sendBackpackGiftWithSendGiftItem:(SendGiftItem *)sendItem {

    int successType = -1;

    // 遍历合成礼物数组 拿到发送的礼物item
    RoomBackGiftItem *backGiftItem = [[RoomBackGiftItem alloc] init];
    NSUInteger index = -1;

    for (RoomBackGiftItem *giftItem in self.roombackGiftArray) {

        if ([giftItem.giftId isEqualToString:sendItem.giftItem.infoItem.giftId]) {
            index = [self.roombackGiftArray indexOfObject:giftItem];
            backGiftItem = giftItem;
        }
    }

    /** 判断背包礼物数量是否够送 */
    int remainNum = backGiftItem.num - sendItem.giftNum;
    if (remainNum > 0) {

        // 添加礼物到发送队列 并发送礼物请求
        [self addItemInQueueAndSend:sendItem];

        // 礼物数量减掉发送数量 替换礼物Object
        backGiftItem.num = remainNum;
        [self.roombackGiftArray replaceObjectAtIndex:index withObject:backGiftItem];
        successType = 1;

    } else if (remainNum == 0) {

        [self addItemInQueueAndSend:sendItem];
        // 礼物送完移出合成礼物队列
        [self.roombackGiftArray removeObjectAtIndex:index];
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

    IMManager *manager = [IMManager manager];
    SendGiftItem *item = self.sendGiftArray[0];

    // 送礼
    [manager sendGift:item.roomID
                 nickName:self.loginManager.loginItem.nickName
                   giftId:item.giftItem.infoItem.giftId
                 giftName:item.giftItem.infoItem.name
               isBackPack:item.isBackPack
                  giftNum:item.giftNum
              multi_click:item.giftItem.infoItem.multiClick
        multi_click_start:item.starNum
          multi_click_end:item.endNum
           multi_click_id:item.clickID
            finishHandler:^(BOOL success, LCC_ERR_TYPE errType, NSString *_Nonnull errMsg, double credit, double rebateCredit) {

                NSLog(@"BackpackSendGiftManager::sendBackGiftQurest( [接收发送背包礼物结果], success : %d, errType : %d, errMsg : %@, credit : %f, rebateCredit : %f)", success, errType, errMsg, credit, rebateCredit);

                dispatch_async(dispatch_get_main_queue(), ^{

                    if (success) {

                        [self.sendGiftArray removeObjectAtIndex:0];
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
}

- (void)updataBackpackGiftList {
    
    
}

- (void)requestSendGiftFail {
    
}



@end
