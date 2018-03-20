//
//  RoomBackGiftItem.h
//  livestream
//
//  Created by randy on 2017/9/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllGiftItem.h"
#import "LiveGiftDownloadManager.h"

@interface RoomBackGiftItem : NSObject

@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) int giftNum;

@end
