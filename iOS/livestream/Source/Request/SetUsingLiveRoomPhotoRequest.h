//
//  SetUsingLiveRoomPhotoRequest.h
//  dating
//  3.12.设置默认使用封面图（用于主播设置默认的封面图）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface SetUsingLiveRoomPhotoRequest : SessionRequest
@property (nonatomic, strong) NSString * _Nullable photoId;
@property (nonatomic, strong) SetUsingLiveRoomPhotoFinishHandler _Nullable finishHandler;
@end
