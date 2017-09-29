//
//  LiveGiftListManager.h
//  livestream
//
//  Created by randy on 2017/8/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveGiftObject.h"
#import "LiveRoomGiftModel.h"
#import "AllGiftItem.h"

@class LiveGiftListManager;
typedef void (^GetGiftFinshHandler)(BOOL success, NSMutableArray *roomShowGiftList, NSMutableArray *roomGiftList);

@interface LiveGiftListManager : NSObject

@property (nonatomic, strong) NSMutableArray *liveGiftArray;

@property (nonatomic, strong) NSMutableArray *showGiftArray;

+ (instancetype)manager;

#pragma mark - 获取直播间可发送礼物列表
- (void)theLiveGiftListRequest:(NSString *)roomId finshHandler:(GetGiftFinshHandler)finshHandler;

#pragma mark - 获取指定礼物详情
- (void)getGiftDetailWithGiftid:(NSString *)giftId;

#pragma mark - 判断礼物是否可发送
- (BOOL)giftCanSendInLiveRoom:(AllGiftItem *)item;

@end
