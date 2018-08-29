//
//  LiveGiftListManager.m
//  livestream
//
//  Created by randy on 2017/8/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveGiftListManager.h"

#import "LiveGiftDownloadManager.h"

@interface LiveGiftListManager ()


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
    }
    return self;
}

#pragma mark - 获取直播间可发送礼物列表
- (void)theLiveGiftListRequest:(NSString *)roomId finshHandler:(GetGiftFinshHandler)finshHandler {
    NSLog(@"LiveGiftListManager::requestTheLiveGiftListWithRoomID( [发送获取直播间可发送礼物列表请求], roomId : %@ )", roomId);

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
