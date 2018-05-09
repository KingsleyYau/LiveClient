
//
//  ZBImLiveRoomObject.h
//  livestream
//
//  Created by Max on 2018/4/9.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnchorGiftNumItemObject.h"

@interface AnchorRecvGiftItemObject : NSObject

/**
 * 已收礼物列表
 * @userId                  用户ID，包括观众及主播
 * @buyforList              已收吧台礼物列表
 */
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, strong) NSArray<AnchorGiftNumItemObject *> *_Nonnull buyforList;

@end
