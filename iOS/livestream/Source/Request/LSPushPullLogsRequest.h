//
//  LSPushPullLogsRequest.h
//  dating
//  6.26.提交上报当前拉流的时间
//  Created by Alex on 20/05/14
//  Copyright © 2020年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSPushPullLogsRequest : LSSessionRequest

// liveRoomId直播间ID
@property (nonatomic, copy) NSString *_Nullable liveRoomId;

@property (nonatomic, strong) PushPullLogsFinishHandler _Nullable finishHandler;
@end
