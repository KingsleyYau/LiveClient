//
//  BackpackGiftItem.h
//  livestream
//
//  Created by randy on 2017/8/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoomGiftItemObject.h"

@interface BackpackGiftItem : NSObject

@property (nonatomic, strong) LiveRoomGiftItemObject *item;

@property (nonatomic, assign) int giftNum;

@property (nonatomic, assign) int granted_date;

@property (nonatomic, assign) int exp_date;

@property (nonatomic, strong) NSArray *send_num_list;

@end
