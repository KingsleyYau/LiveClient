//
//  GetLiveRoomFansListRequest.h
//  dating
//  3.4.获取直播间观众头像列表（限定数量）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomFansListRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable roomId;
@property (nonatomic,strong) GetLiveRoomFansListFinishHandler _Nullable finishHandler;
@end
