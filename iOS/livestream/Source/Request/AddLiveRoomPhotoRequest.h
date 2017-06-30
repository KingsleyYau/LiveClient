//
//  AddLiveRoomPhotoRequest.h
//  dating
//  3.11.添加开播封面图（用于主播添加开播封面图）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface AddLiveRoomPhotoRequest : SessionRequest
@property (nonatomic, strong) NSString * _Nullable photoId;
@property (nonatomic, strong) AddLiveRoomPhotoFinishHandler _Nullable finishHandler;
@end
