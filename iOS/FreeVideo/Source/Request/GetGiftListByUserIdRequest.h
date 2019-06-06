//
//  GetGiftListByUserIdRequest.h
//  dating
//  3.6.获取直播间可发送的礼物列表（观众端/主播端获取直播间的可发送的礼物列表, 包括背包礼物）接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface GetGiftListByUserIdRequest : LSSessionRequest
// 直播间ID
@property (nonatomic, copy) NSString* _Nonnull roomId;
@property (nonatomic, strong) GetGiftListByUserIdFinishHandler _Nullable finishHandler;
@end
