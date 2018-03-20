
//
//  ZBImLoginRoomObject.h
//  livestream
//
//  Created by Max on 2017/11/03.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IZBImClientDef.h"

@interface ZBImLoginRoomObject : NSObject

/**
 * 直播间结构体
 * roomId                   直播间ID
 * roomType                 直播间类型
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, assign) ZBRoomType roomType;

@end
