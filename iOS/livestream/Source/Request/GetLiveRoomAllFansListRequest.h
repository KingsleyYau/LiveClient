//
//  GetLiveRoomAllFansListRequest.h
//  dating
//  3.5.获取直播间所有观众头像列表
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLiveRoomAllFansListRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable roomId;
@property (nonatomic, assign) int start;
@property (nonatomic, assign) int step;
@property (nonatomic,strong) GetLiveRoomAllFansListFinishHandler _Nullable finishHandler;
@end
