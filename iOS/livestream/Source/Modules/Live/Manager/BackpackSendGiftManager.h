//
//  BackpackSendGiftManager.h
//  livestream
//
//  Created by randy on 2017/8/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackpackGiftItem.h"

@class BackpackSendGiftManager;
typedef void (^SendBackpackGiftBlock)(BOOL success,NSMutableArray *backArray);

@interface BackpackSendGiftManager : NSObject

@property (nonatomic, strong) NSMutableArray *backGiftArray;

@property (nonatomic, strong) BackpackGiftItem *backpackItem;

+ (instancetype)backpackGiftManager;

- (void)sendBackpackGiftID:(NSString *)giftID giftNum:(int)giftNum statNum:(int)starNum endNum:(int)endNum finishHanld:(SendBackpackGiftBlock)block;

- (void)updataBackpackGiftList;

- (void)requestSendGiftFail;

@end
