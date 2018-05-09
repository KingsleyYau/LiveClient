//
//  AnchorHangoutGiftListObject.h
//  dating
//
//  Created by Alex on 18/4/4.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBGiftLimitNumItemObject.h"

@interface AnchorHangoutGiftListObject : NSObject
/**
 * 多人互动直播间礼物列表
 * buyforList            吧台礼物列表
 * normalList           连击礼物&大礼物列表
 * celebrationList      庆祝礼物列表
 */

/* 发送可选数量列表 */
@property (nonatomic, strong) NSMutableArray<ZBGiftLimitNumItemObject *>* buyforList;
/* 发送可选数量列表 */
@property (nonatomic, strong) NSMutableArray<ZBGiftLimitNumItemObject *>* normalList;
/* 发送可选数量列表 */
@property (nonatomic, strong) NSMutableArray<ZBGiftLimitNumItemObject *>* celebrationList;
@end
