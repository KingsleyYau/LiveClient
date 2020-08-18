//
//  LSGiftManager.m
//  livestream
//
//  Created by randy on 2017/6/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGiftManager.h"

#import "LSLoginManager.h"

#import "LSFileCacheManager.h"
#import "LSImageViewLoader.h"
#import "LSYYImage.h"

#import "LSSessionRequestManager.h"
#import "GiftListRequest.h"
#import "GetGiftDetailRequest.h"
#import "GetGiftListByUserIdRequest.h"

@interface LSGiftManager () <LoginManagerDelegate, LSGiftManagerItemDownloadDelegate>
// 登录管理器
@property (nonatomic, strong) LSLoginManager *loginManager;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
// 是否第一次登录
@property (nonatomic, assign) BOOL isFirstLogin;
// 所有礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *giftMutableArray;
// 直播间礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *giftRoomMutableArray;
// 直播间礼物当前请求
@property (nonatomic, strong) GetGiftListByUserIdRequest *giftRoomRequest;
// 所有背包礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *giftBackpackMutableArray;
// 直播间背包礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *giftRoomBackpackMutableArray;
// 直播间背包礼物请求
@property (nonatomic, strong) GiftListRequest *giftRoomBackpackRequest;
// 多人互动直播间吧台礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *buyforMutableArray;
// 多人互动直播间普通礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *normalMutableArray;
// 多人互动直播间庆祝礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *celebrationMutableArray;
// 多人互动直播间礼物请求
@property (nonatomic, strong) LSGetHangoutGiftListRequest *hangoutGiftListRequest;

// Free礼物对象数组
@property (nonatomic, strong) NSMutableArray<LSGiftManagerItem *> *freeGiftArray;
@end

@implementation LSGiftManager
+ (instancetype)manager {
    static LSGiftManager *giftDownloadManager = nil;
    if (giftDownloadManager == nil) {
        giftDownloadManager = [[LSGiftManager alloc] init];
    }
    return giftDownloadManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        self.isFirstLogin = YES;

        self.sessionManager = [LSSessionRequestManager manager];

        // 所有礼物
        self.giftMutableArray = [[NSMutableArray alloc] init];
        self.giftRoomMutableArray = [[NSMutableArray alloc] init];

        // 背包
        self.giftBackpackMutableArray = [[NSMutableArray alloc] init];
        self.giftRoomBackpackMutableArray = [[NSMutableArray alloc] init];

        // 多人互动直播间
        self.buyforMutableArray = [[NSMutableArray alloc] init];
        self.normalMutableArray = [[NSMutableArray alloc] init];
        self.celebrationMutableArray = [[NSMutableArray alloc] init];

        self.freeGiftArray = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)giftArray {
    return self.giftMutableArray;
}

- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            if (self.isFirstLogin) {
                // 第一次登录成功, 获取所有礼物列表
                NSLog(@"LSGiftManager::onLogin( [HTTP登陆, 成功(第一次), 获取背包礼物及所有礼物列表] )");
                [self getAllGiftList:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList){
                }];
            }
        }
    });
}

- (void)manager:(LSLoginManager *)manager onLogout:(LogoutType)type msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LSGiftManager::onLogout( [登录注销] )");
        self.isFirstLogin = YES;
        [self removeAllGiftList];
    });
}

#pragma mark - 获取礼物
- (void)getAllGiftList:(GetGiftFinshtHandler)finshHandler {
    // TODO:获取礼物列表
    NSLog(@"LSGiftManager::getAllGiftList( [获取所有礼物列表] )");
    if (self.giftMutableArray.count) {
        NSLog(@"LSGiftManager::getAllGiftList( [获取所有礼物列表], Success, count : %u )", (unsigned int)self.giftMutableArray.count);

        if (finshHandler) {
            finshHandler(YES, self.giftMutableArray);
        }

    } else {
        GetAllGiftListRequest *request = [[GetAllGiftListRequest alloc] init];
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<GiftInfoItemObject *> *_Nullable array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"LSGiftManager::getAllGiftList( [获取所有礼物列表], %@, errnum : %ld, errmsg : %@, count : %u )", BOOL2SUCCESS(success), (long)errnum, errmsg, (unsigned int)array.count);
                if (success) {
                    // 清空旧数据
                    [self.giftMutableArray removeAllObjects];

                    // 增加新礼物
                    int i = 0;
                    for (GiftInfoItemObject *object in array) {
                        LSGiftManagerItem *allItem = [[LSGiftManagerItem alloc] init];
                        allItem.infoItem = object;
                        allItem.index = i++;

                        // 下载礼物
                        allItem.delegate = self;
                        [allItem download];

                        [self.giftMutableArray addObject:allItem];
                    }

                    self.isFirstLogin = NO;

                    if (finshHandler) {
                        finshHandler(success, self.giftMutableArray);
                    }
                } else {
                    if (finshHandler) {
                        finshHandler(success, self.giftMutableArray);
                    }
                }
            });
        };
        [self.sessionManager sendRequest:request];
    }
}

- (void)getRoomGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler {
    // TODO:获取直播间可发送礼物列表
    NSLog(@"LSGiftManager::getRoomGiftList( [获取直播间可发送礼物列表], roomId : %@ )", roomId);

    [self getAllGiftList:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        if (success) {
            if (self.giftRoomMutableArray.count > 0) {
                NSLog(@"LSGiftManager::getRoomGiftList( [获取直播间可发送礼物列表], Success, roomId : %@, count : %u )", roomId, (unsigned int)self.giftRoomMutableArray.count);

                if (finshHandler) {
                    finshHandler(YES, self.giftRoomMutableArray);
                }

            } else {
                // 发送请求
                GetGiftListByUserIdRequest *request = [[GetGiftListByUserIdRequest alloc] init];
                request.roomId = roomId;
                request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<GiftWithIdItemObject *> *_Nullable array) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 只有当前请求才处理
                        //                        if( self.giftRoomRequest == request ) {
                        //                            self.giftRoomRequest = nil;

                        // 清空旧数据
                        [self.giftRoomMutableArray removeAllObjects];
                        [self.freeGiftArray removeAllObjects];

                        if (success) {
                            // 增加新礼物
                            for (GiftWithIdItemObject *item in array) {
                                // if (item.isShow) {
                                // 只返回可显示的礼物
                                LSGiftManagerItem *giftManagerItem = [self getGiftItemWithId:item.giftId];
                                giftManagerItem.roomInfoItem = item;
                                if (giftManagerItem.infoItem) {
                                    [self.giftRoomMutableArray addObject:giftManagerItem];
                                }
                                //}
                                //                                    if (item.isFree) {
                                //                                        LSGiftManagerItem *giftManagerItem = [self getGiftItemWithId:item.giftId];
                                //                                        giftManagerItem.roomInfoItem = item;
                                //                                        if (giftManagerItem.infoItem) {
                                //                                            [self.freeGiftArray addObject:giftManagerItem];
                                //                                        }
                                //                                    }
                            }
                        }

                        NSLog(@"LSGiftManager::getRoomGiftList( [获取直播间可发送礼物列表], %@, roomId : %@, errnum : %ld, errmsg : %@, requestCount : %u, localCount : %u )", BOOL2SUCCESS(success), roomId, (long)errnum, errmsg, (unsigned int)array.count, (unsigned int)self.giftRoomMutableArray.count);

                        if (finshHandler) {
                            finshHandler(success, self.giftRoomMutableArray);
                        }
                        //                        }
                    });
                };
                //                self.giftRoomRequest = request;
                [self.sessionManager sendRequest:request];
            }
        } else {
            if (finshHandler) {
                finshHandler(NO, giftList);
            }
        }
    }];
}

- (void)getRoomRandomGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler {
    // TODO:获取直播间随机礼物列表
    NSLog(@"LSGiftManager::getRoomRandomGiftList( [获取直播间随机礼物列表], roomId : %@ )", roomId);

    [self getRoomGiftList:roomId
             finshHandler:^(BOOL success, NSArray *giftList) {
                 NSMutableArray *giftPromptList = [NSMutableArray array];

                 if (success) {
                     for (LSGiftManagerItem *item in giftList) {
                         if (item.roomInfoItem.isPromo) {
                             // 推广的随机礼物
                             if (item.infoItem) {
                                 [giftPromptList addObject:item];
                             }
                         }
                     }
                 }

                 NSLog(@"LSGiftManager::getRoomRandomGiftList( [获取直播间随机礼物列表], %@, roomId : %@, count : %u )", BOOL2SUCCESS(success), roomId, (unsigned int)giftPromptList.count);

                 if (finshHandler) {
                     finshHandler(success, giftPromptList);
                 }
             }];
}

- (void)getAllBackpackGiftList:(GetGiftFinshtHandler)finshHandler {
    // TODO:获取所有背包礼物列表
    NSLog(@"LSGiftManager::getAllBackpackGiftList( [获取所有背包礼物列表] )");

    // 先确定所有礼物列表已经下载完成
    [self getAllGiftList:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        if (success) {
            if (self.giftBackpackMutableArray.count) {
                NSLog(@"LSGiftManager::getAllBackpackGiftList( [获取所有背包礼物列表], Success, count : %u )", (unsigned int)self.giftBackpackMutableArray.count);

                if (finshHandler) {
                    finshHandler(YES, self.giftBackpackMutableArray);
                }

            } else {
                GiftListRequest *request = [[GiftListRequest alloc] init];
                request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg,
                                          NSArray<BackGiftItemObject *> *_Nullable array, int totalCount) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 只有当前请求才处理
                        if (self.giftRoomBackpackRequest == request) {
                            NSLog(@"LSGiftManager::getAllBackpackGiftList( [获取所有背包礼物列表], %@, errnum : %ld, errmsg : %@, totalCount : %d )", BOOL2SUCCESS(success), (long)errnum, errmsg, totalCount);
                            if (success) {
                                // 新增数据, 并根据Id做合并
                                NSInteger time = [[NSDate date] timeIntervalSince1970];
                                for (BackGiftItemObject *item in array) {
                                    LSGiftManagerItem *giftManagerItem = [self getGiftItemWithId:item.giftId];
                                    // 是否在有效期内
                                    if (time >= item.startValidDate && time <= item.expDate) {
                                        giftManagerItem.backpackTotal += item.num;
                                        // 判断队列是否包含该对象
                                        BOOL isContains = [self.giftBackpackMutableArray containsObject:giftManagerItem];
                                        if (giftManagerItem.infoItem && !isContains) {
                                            [self.giftBackpackMutableArray addObject:giftManagerItem];
                                        }
                                    }
                                }
                            }

                            if (finshHandler) {
                                finshHandler(success, self.giftBackpackMutableArray);
                            }
                        }
                    });
                };
                self.giftRoomBackpackRequest = request;
                [self.sessionManager sendRequest:request];
            }
        }
    }];
}

- (void)getRoomBackpackGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler {
    // TODO:获取直播间可显示的背包礼物列表
    NSLog(@"LSGiftManager::getRoomBackpackGiftList( [获取直播间可显示的背包礼物列表], roomId : %@ )", roomId);

    // 确定所有背包礼物列表已经下载完成
    [self getAllBackpackGiftList:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        if (success) {
            // 清除旧数据
            [self.giftRoomBackpackMutableArray removeAllObjects];
            for (LSGiftManagerItem *item in self.giftBackpackMutableArray) {
                if (item.backpackTotal > 0) {
                    [self.giftRoomBackpackMutableArray addObject:item];
                }
            }

            if (finshHandler) {
                finshHandler(success, self.giftRoomBackpackMutableArray);
            }

        } else {
            if (finshHandler) {
                finshHandler(NO, nil);
            }
        }
    }];
}

- (void)getPraviteRoomBackpackGiftList:(NSString *)roomId finshHandler:(GetGiftFinshtHandler)finshHandler {
    // TODO:获取私密直播间可显示的背包礼物列表
    NSLog(@"LSGiftManager::getPraviteRoomBackpackGiftList( [获取私密直播间可显示的背包礼物列表], roomId : %@ )", roomId);
    [self getRoomGiftList:roomId
             finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
                 NSLog(@"LSGiftManager::getPraviteRoomBackpackGiftList( [获取私密直播间可显示的背包礼物列表], %@, count : %lu)", BOOL2SUCCESS(success), (unsigned long)giftList.count);
                 if (giftList.count > 0) {
                     [self getAllBackpackGiftList:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
                         NSLog(@"LSGiftManager::getPraviteRoomBackpackGiftList( [获取私密直播间所有背包礼物列表], %@, count : %lu)", BOOL2SUCCESS(success), (unsigned long)giftList.count);
                         if (success) {
                             // 清除旧数据
                             [self.giftRoomBackpackMutableArray removeAllObjects];
                             // 遍历所有背包礼物
                             for (LSGiftManagerItem *item in self.giftBackpackMutableArray) {
                                 // 如果总数大于0 并且在直播间可发送礼物列表中 则显示
                                 if (item.backpackTotal > 0 && self.giftRoomMutableArray.count > 0) {
                                     for (LSGiftManagerItem *giftItem in self.giftRoomMutableArray) {
                                         if ([item.giftId isEqualToString:giftItem.giftId]) {
                                             [self.giftRoomBackpackMutableArray addObject:item];
                                         }
                                     }
                                 }
                             }

                             if (finshHandler) {
                                 finshHandler(success, self.giftRoomBackpackMutableArray);
                             }

                         } else {
                             if (finshHandler) {
                                 finshHandler(NO, nil);
                             }
                         }
                     }];
                 } else {
                     if (finshHandler) {
                         finshHandler(NO, nil);
                     }
                 }
             }];
}

- (void)getHangoutGiftList:(NSString *)roomId finshHandler:(GetHangoutGiftFinshHandler)finshHandler {
    NSLog(@"LSGiftManager::getHangoutGiftList( [获取多人互动直播间可发送礼物列表] )");
    // TODO:获取多人互动直播间可发送礼物列表
    BOOL haveBuyFor = self.buyforMutableArray.count > 0 ? YES : NO;
    BOOL haveNormal = self.normalMutableArray.count > 0 ? YES : NO;
    BOOL haveCelebration = self.celebrationMutableArray.count > 0 ? YES : NO;

    [self getAllGiftList:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        if (success) {
            if (haveBuyFor & haveNormal & haveCelebration) {
                NSLog(@"LSGiftManager::getHangoutGiftList( [获取多人互动直播间可发送礼物列表], Success, roomId : %@, buyforCount : %u, normalCount : %u, celebrationCount : %u )", roomId, (unsigned int)self.buyforMutableArray.count, (unsigned int)self.normalMutableArray.count, (unsigned int)self.celebrationMutableArray.count);

                if (finshHandler) {
                    finshHandler(YES, self.buyforMutableArray, self.normalMutableArray, self.celebrationMutableArray);
                }
            } else {
                LSGetHangoutGiftListRequest *request = [[LSGetHangoutGiftListRequest alloc] init];
                request.roomId = roomId;
                request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSHangoutGiftListObject *_Nonnull item) {
                    NSLog(@"LSGiftManager::( [请求多人互动可发送礼物列表], %@, roomId : %@, errnum : %d, errmsg : %@, buyforList : %lu, normalList : %lu, celebrationList : %lu )", BOOL2SUCCESS(success), roomId, errnum, errmsg, item.buyforList.count, item.normalList.count, item.celebrationList.count);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.hangoutGiftListRequest == request) {
                            self.hangoutGiftListRequest = nil;

                            [self.buyforMutableArray removeAllObjects];
                            [self.normalMutableArray removeAllObjects];
                            [self.celebrationMutableArray removeAllObjects];

                            if (success) {
                                for (NSString *giftId in item.buyforList) {
                                    // 吧台礼物
                                    LSGiftManagerItem *giftManagerItem = [self getGiftItemWithId:giftId];
                                    if (giftManagerItem.infoItem) {
                                        [self.buyforMutableArray addObject:giftManagerItem];
                                    }
                                }
                                for (NSString *giftId in item.normalList) {
                                    // 普通礼物
                                    LSGiftManagerItem *giftManagerItem = [self getGiftItemWithId:giftId];
                                    if (giftManagerItem.infoItem) {
                                        [self.normalMutableArray addObject:giftManagerItem];
                                    }
                                }
                                for (NSString *giftId in item.celebrationList) {
                                    // 普通礼物
                                    LSGiftManagerItem *giftManagerItem = [self getGiftItemWithId:giftId];
                                    if (giftManagerItem.infoItem) {
                                        [self.celebrationMutableArray addObject:giftManagerItem];
                                    }
                                }
                            }

                            if (finshHandler) {
                                finshHandler(success, self.buyforMutableArray, self.normalMutableArray, self.celebrationMutableArray);
                            }
                        }
                    });
                };
                self.hangoutGiftListRequest = request;
                [self.sessionManager sendRequest:request];
            }
        }
    }];
}

- (void)getGiftTypeList:(NSInteger)roomType finshHandler:(GetGiftTypeListFinishHandler)finshHandler {
    //TODO:获取虚拟礼物分类列表

    LSGetGiftTypeListRequest *request = [[LSGetGiftTypeListRequest alloc] init];
    request.roomType = roomType == 1 ? LSGIFTROOMTYPE_PUBLIC : LSGIFTROOMTYPE_PRIVATE;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSGiftTypeItemObject *> *array) {

        if (finshHandler) {
            finshHandler(success, errnum, errmsg, array);
        }
    };
    [self.sessionManager sendRequest:request];
}

- (void)getGiftTypeContent:(NSString *)roomId typeID:(NSString *)typeId finshHandler:(GetGiftFinshtHandler)finshHandler {

    [self getRoomGiftList:roomId
             finshHandler:^(BOOL success, NSArray *giftList) {
                 NSMutableArray *typeArray = [NSMutableArray array];

                 if (success) {
                     for (LSGiftManagerItem *item in giftList) {
                         if (item.roomInfoItem) {
                             if ([item.roomInfoItem.typeIdList containsObject:typeId]) {
                                 [typeArray addObject:item];
                             }
                         }
                     }
                 }

                 NSLog(@"LSGiftManager::getRoomGiftList( [根据礼物类型ID获取礼物列表], %@, roomId : %@, typeId:%@, count : %u )", BOOL2SUCCESS(success), roomId, typeId, (unsigned int)typeArray.count);

                 if (finshHandler) {
                     finshHandler(success, typeArray);
                 }
             }];
}

- (LSGiftManagerItem *)getGiftItemWithId:(NSString *)giftId {
    // TODO:获取单个礼物
    //    NSLog(@"LSGiftManager::getGiftItemWithId( [获取单个礼物], giftId : %@ )", giftId);

    LSGiftManagerItem *item = nil;
    // 本地查找
    for (LSGiftManagerItem *giftItem in self.giftMutableArray) {
        if ([giftItem.giftId isEqualToString:giftId]) {
            item = giftItem;
            break;
        }
    }

    // 创建新的礼物
    if (!item) {
        item = [[LSGiftManagerItem alloc] init];
        item.giftId = giftId;
        item.delegate = self;
        item.index = self.giftMutableArray.count;
        [self.giftMutableArray addObject:item];
    }

    // 未获取详情
    if (item.infoItem == nil) {
        // 向服务器请求单个礼物详情
        [self requestGiftItemWithGiftID:giftId];
    }

    return item;
}

- (void)removeAllGiftList {
    // TODO:清除所有缓存礼物列表
    NSLog(@"LSGiftManager::removeAllGiftList( [清除所有缓存礼物列表] )");

    [self removeRoomGiftList];
    [self.giftMutableArray removeAllObjects];
}

- (void)removeRoomGiftList {
    // TODO:清除直播间缓存礼物列表
    NSLog(@"LSGiftManager::removeRoomGiftList( [清除直播间缓存礼物列表], request : %p )", self.giftRoomRequest);
    [self.giftBackpackMutableArray removeAllObjects];
    self.giftRoomRequest = nil;
    [self.giftRoomMutableArray removeAllObjects];
    self.giftRoomBackpackRequest = nil;
    [self.giftRoomBackpackMutableArray removeAllObjects];
    [self.freeGiftArray removeAllObjects];
    // 清空旧数据
    for (LSGiftManagerItem *giftManagerItem in self.giftMutableArray) {
        giftManagerItem.backpackTotal = 0;
    }
}

- (void)removeHangoutGiftList {
    // TODO:清除多人互动直播间缓存礼物列表

    self.hangoutGiftListRequest = nil;
    [self.buyforMutableArray removeAllObjects];
    [self.normalMutableArray removeAllObjects];
    [self.celebrationMutableArray removeAllObjects];
}

#pragma mark - 私有方法
- (void)requestGiftItemWithGiftID:(NSString *)giftId {
    // TODO:请求指定礼物
    GetGiftDetailRequest *request = [[GetGiftDetailRequest alloc] init];
    request.giftId = giftId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, GiftInfoItemObject *_Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                BOOL bFlag = NO;
                LSGiftManagerItem *allItem = nil;
                for (int i = 0; i < self.giftMutableArray.count; i++) {
                    allItem = self.giftMutableArray[i];
                    if ([allItem.giftId isEqualToString:giftId]) {
                        // 更新礼物属性
                        allItem.infoItem = item;
                        // 重新下载
                        [allItem download];
                        // 标记找到
                        bFlag = YES;
                        break;
                    }
                }
                
                if( bFlag && allItem ) {
                    if ([self.delegate respondsToSelector:@selector(giftDownloadManagerStateChange:index:)]) {
                        [self.delegate giftDownloadManagerStateChange:allItem index:allItem.index];
                    }
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)giftDownloadStateChange:(LSGiftManagerItem *)giftItem {
    // TODO:下载礼物回调
    if ([self.delegate respondsToSelector:@selector(giftDownloadManagerBigGiftChange:index:)]) {
        [self.delegate giftDownloadManagerBigGiftChange:giftItem index:giftItem.index];
    }
}

@end

