//
//  SetLiveRoomModifyInfoRequest.h
//  dating
//  3.4.获取直播间观众头像列表
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface SetLiveRoomModifyInfoRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable photoId;
@property (nonatomic, strong) NSString* _Nullable nickName;
@property (nonatomic, assign) Gender gender;
@property (nonatomic, strong) NSString* _Nullable birthday;
@property (nonatomic, strong) SetLiveRoomModifyInfoFinishHandler _Nullable finishHandler;
@end
