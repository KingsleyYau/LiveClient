//
//  LiveGiftDownloadManager.h
//  livestream
//
//  Created by randy on 2017/6/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetLiveRoomAllGiftListRequest.h"

@interface LiveGiftDownloadManager : NSObject

@property (nonatomic, retain) NSString *path;

+ (instancetype)giftDownloadManager;

// 根据礼物id拿到礼物model
- (LiveRoomGiftItemObject *)backGiftItemWithGiftID:(NSString *)giftId;

// 根据礼物id拿到webP文件
- (NSData *)doCheckLocalGiftWithGiftID:(NSString *)giftId;

// 根据礼物id拿到礼物SmallImgUrl
- (NSString *)backSmallImgUrlWithGiftID:(NSString *)giftId;

// 根据礼物id拿到礼物ImgUrl
- (NSString *)backImgUrlWithGiftID:(NSString *)giftId;

@end
