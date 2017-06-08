//
//  UpdateLiveRoomTokenIdRequest.h
//  dating
//  2.6.上传tokenid接口
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface UpdateLiveRoomTokenIdRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable tokenId;
@property (nonatomic, strong) UpdateLiveRoomTokenIdFinishHandler _Nullable finishHandler;
@end
