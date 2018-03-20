//
//  ControlManPushRequest.h
//  dating
//  3.13.观众开始／结束视频互动（废弃）
//  Created by Alex on 17/8/30
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface ControlManPushRequest : LSSessionRequest
// 直播间ID
@property (nonatomic, copy) NSString * _Nullable  roomId;
@property (nonatomic, assign) ControlType control;
@property (nonatomic, strong) ControlManPushFinishHandler _Nullable finishHandler;
@end
