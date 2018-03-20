//
//  LiveGiftListManager.m
//  livestream
//
//  Created by randy on 2017/8/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveGiftListManager.h"
#import "GetGiftListByUserIdRequest.h"
#import "GetGiftDetailRequest.h"
#import "LSSessionRequestManager.h"
#import "LiveGiftDownloadManager.h"

@interface LiveGiftListManager ()

/** 接口管理器 **/
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@end

@implementation LiveGiftListManager

+ (instancetype)manager {

    static LiveGiftListManager *manager = nil;

    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    //        manager = [[LiveGiftListManager alloc] init];
    if (manager == nil) {
        manager = [[LiveGiftListManager alloc] init];
    }
    //    });

    return manager;
}

- (instancetype)init {

    self = [super init];
    if (self) {
        self.liveGiftArray = [[NSMutableArray alloc] init];
        self.showGiftArray = [[NSMutableArray alloc] init];
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

#pragma mark - 获取直播间可发送礼物列表
- (void)theLiveGiftListRequest:(NSString *)roomId finshHandler:(GetGiftFinshHandler)finshHandler {
    NSLog(@"LiveGiftListManager::requestTheLiveGiftListWithRoomID( [发送获取直播间可发送礼物列表请求], roomId : %@ )", roomId);

    GetGiftListByUserIdRequest *request = [[GetGiftListByUserIdRequest alloc] init];
    request.roomId = roomId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg,
                              NSArray<GiftWithIdItemObject *> *_Nullable array) {

        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LiveGiftListManager::requestTheLiveGiftListWithRoomID( [发送获取直播间可发送礼物列表请求结果], roomId : %@, success : %s, errnum : %ld, errmsg : %@, count : %u )", roomId, success ? "true" : "false", (long)errnum, errmsg, (unsigned int)array.count);

            if (success) {
                // 成功清除旧数据
                [self.liveGiftArray removeAllObjects];
                [self.showGiftArray removeAllObjects];
                
                if (array && array.count != 0) {
                    for (int i = 0; i < array.count; i++) {
                        GiftWithIdItemObject *item = array[i];
                        LiveRoomGiftModel *model = [[LiveRoomGiftModel alloc] init];
                        model.giftId = item.giftId;
                        model.isShow = item.isShow;
                        model.isPromo = item.isPromo;
                        [self.liveGiftArray addObject:model];
                        if (model.isShow) {
                            [self.showGiftArray addObject:model];
                        }
                        // 查询所有礼物列表中是否有该礼物
                        AllGiftItem *allItem = [[LiveGiftDownloadManager manager].giftDictionary valueForKey:model.giftId];
                        if (!allItem) {
                            [self getGiftDetailWithGiftid:model.giftId];
                        }
                    }
                    finshHandler(success, self.showGiftArray, self.liveGiftArray);
                }
            } else {
                finshHandler(success, nil, nil);
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 获取指定礼物详情
- (void)getGiftDetailWithGiftid:(NSString *)giftId {
    GetGiftDetailRequest *request = [[GetGiftDetailRequest alloc] init];
    request.giftId = giftId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, GiftInfoItemObject *_Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 添加新礼物到本地
            if (success) {
                AllGiftItem *allItem = [[AllGiftItem alloc] init];
                allItem.infoItem = item;
                [[LiveGiftDownloadManager manager].giftMuArray addObject:allItem];
                [[LiveGiftDownloadManager manager] downLoadGiftDetail:giftId];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

// 判断礼物是否可发送
- (BOOL)giftCanSendInLiveRoom:(AllGiftItem *)item {

    BOOL isCan = NO;

    if (self.liveGiftArray && self.liveGiftArray.count) {

        for (LiveRoomGiftModel *model in self.liveGiftArray) {

            if ([model.giftId isEqualToString:item.infoItem.giftId]) {

                isCan = YES;
            }
        }
    }
    return isCan;
}

@end
