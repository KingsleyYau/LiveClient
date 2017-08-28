//
//  LiveGiftListManager.h
//  livestream
//
//  Created by randy on 2017/8/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveGiftObject.h"

@class LiveGiftListManager;
typedef void (^RequestFinshtBlock)(BOOL success,NSMutableArray *backArray);

@interface LiveGiftListManager : NSObject

@property (nonatomic, strong) NSMutableArray *liveGiftArray;

@property (nonatomic, strong) NSMutableArray *showGiftArray;

+ (instancetype)liveGiftListManager;

- (void)requestTheLiveGiftListWithRoomID:(NSString *)roomId callBack:(RequestFinshtBlock)back;

@end
