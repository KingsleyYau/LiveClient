//
//  LSGetHangoutOnlineAnchorRequest.h
//  dating
//  8.7.获取Hang-out在线主播列表
//  Created by Alex on 18/1/21
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSGetHangoutOnlineAnchorRequest : LSSessionRequest
@property (nonatomic, strong) GetHangoutOnlineAnchorFinishHandler _Nullable finishHandler;
@end
