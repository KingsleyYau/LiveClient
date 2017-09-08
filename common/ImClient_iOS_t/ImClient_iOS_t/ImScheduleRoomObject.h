
//
//  ImScheduleRoomObject.h
//  livestream
//
//  Created by Max on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "IImClientDef.h"

@interface ImScheduleRoomObject : NSObject

/**
 * 立即私密邀请结构体
 * anchorImg                主播头像url
 * anchorCoverImg           主播封面图url
 * anchorCoverImg		    最晚可进入的时间（1970年起的秒数）
 * roomId                   直播间ID
 */
@property (nonatomic, copy) NSString *_Nonnull anchorImg;
@property (nonatomic, copy) NSString *_Nonnull anchorCoverImg;
@property (nonatomic, assign) NSInteger canEnterTime;
@property (nonatomic, copy) NSString *_Nonnull roomId;

@end
