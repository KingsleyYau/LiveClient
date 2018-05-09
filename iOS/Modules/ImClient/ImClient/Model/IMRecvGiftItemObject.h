
//
//  IMRecvGiftItemObject.h
//  livestream
//
//  Created by Max on 2018/4/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGiftNumItemObject.h"

@interface IMRecvGiftItemObject : NSObject

/**
 * 已收礼物列表
 * @userId                  用户ID，包括观众及主播
 * @buyforList              已收吧台礼物列表
 */
@property (nonatomic, copy) NSString *_Nonnull userId;
@property (nonatomic, strong) NSArray<IMGiftNumItemObject *> *_Nonnull buyforList;

@end
