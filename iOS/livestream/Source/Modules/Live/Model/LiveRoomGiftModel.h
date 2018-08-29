//
//  LiveRoomGiftModel.h
//  livestream
//
//  Created by randy on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSGiftManagerItem.h"
#import "LSGiftManager.h"

@interface LiveRoomGiftModel : NSObject

/**
 * 礼物显示结构体
 * giftId   礼物ID
 * isShow   是否在礼物列表显示（0:否 1:是） （不包括背包礼物列表）
 */
@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isPromo;
@property (nonatomic, strong) LSGiftManagerItem *allItem;

@end
