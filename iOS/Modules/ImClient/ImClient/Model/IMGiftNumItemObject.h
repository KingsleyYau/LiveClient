
//
//  IMGiftNumItemObject.h
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

@interface IMGiftNumItemObject : NSObject

/**
 * 礼物列表
 * @giftId            礼物ID
 * @giftNum           已收礼物数量
 */
@property (nonatomic, copy) NSString *_Nonnull giftId;
@property (nonatomic, assign) int giftNum;

@end
