//
//  DelLiveRoomPhotoRequest.h
//  dating
//  3.13.删除开播封面图（用于主播删除开播封面图）
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface DelLiveRoomPhotoRequest : SessionRequest
@property (nonatomic, strong) NSString * _Nullable photoId;
@property (nonatomic, strong) DelLiveRoomPhotoFinishHandler _Nullable finishHandler;
@end
