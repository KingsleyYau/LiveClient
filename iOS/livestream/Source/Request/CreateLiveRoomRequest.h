//
//  CreateLiveRoomRequest.h
//  dating
//  3.1.新建直播间
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface CreateLiveRoomRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable roomName;
@property (nonatomic, strong) NSString* _Nullable roomPhotoId;
@property (nonatomic, strong) CreateLiveRoomFinishHandler _Nullable finishHandler;
@end
