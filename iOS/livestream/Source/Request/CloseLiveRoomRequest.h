//
//  CloseLiveRoomRequest.h
//  dating
//  3.3.关闭直播间
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface CloseLiveRoomRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable roomId;
@property (nonatomic, strong) CloseLiveRoomFinishHandler _Nullable finishHandler;
@end
