//
//  LSGetGiftTypeListRequest.h
//  dating
//  3.17.获取虚拟礼物分类列
//  Created by Alex on 19/08/27
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetGiftTypeListRequest : LSSessionRequest

/**
 *  3.17.获取虚拟礼物分类列接口
 *
 * roomType         场次类型(LSGIFTROOMTYPE_PUBLIC : 公开, LSGIFTROOMTYPE_PRIVATE : 私密)
 * finishHandler    接口回调s
 */
@property (nonatomic, assign) LSGiftRoomType roomType;
@property (nonatomic, strong) GetGiftTypeListFinishHandler _Nullable finishHandler;
@end
