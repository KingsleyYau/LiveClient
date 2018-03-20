//
//  RandomGiftModel.h
//  livestream
//
//  Created by randy on 2017/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoomGiftModel.h"

@interface RandomGiftModel : NSObject

@property (nonatomic, assign) NSInteger randomInteger;

@property (nonatomic, strong) LiveRoomGiftModel *giftModel;

@end
