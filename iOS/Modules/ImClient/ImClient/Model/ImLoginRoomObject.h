
//
//  ImLoginRoomObject.h
//  livestream
//
//  Created by Max on 2017/11/03.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

@interface ImLoginRoomObject : NSObject

/**
 * 直播间结构体
 * roomId                   直播间ID
 * anchorId                 主播ID
 * nickName                 主播昵称
 */
@property (nonatomic, copy) NSString *_Nonnull roomId;
@property (nonatomic, copy) NSString *_Nonnull anchorId;
@property (nonatomic, copy) NSString *_Nonnull nickName;

@end
